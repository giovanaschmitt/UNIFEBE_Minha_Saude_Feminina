package br.unifebe.minhasaudefeminina.service;

import br.unifebe.minhasaudefeminina.dao.MidiaDao;
import br.unifebe.minhasaudefeminina.exception.RequisicaoInvalidaException;
import br.unifebe.minhasaudefeminina.model.Midia;
import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.util.Set;
import java.util.UUID;

@Service
public class MidiaService {

    private static final Set<String> EXTENSOES_IMAGEM = Set.of("png", "jpg", "jpeg", "gif", "webp");
    private static final Set<String> EXTENSOES_VIDEO = Set.of("mp4", "webm");
    private static final long TAMANHO_MAXIMO_BYTES = 25L * 1024 * 1024;
    private static final int NOME_ORIGINAL_MAXIMO = 255;

    @Value("${midia.diretorio}")
    private String diretorio;

    private final MidiaDao midiaDao;

    public MidiaService(MidiaDao midiaDao) {
        this.midiaDao = midiaDao;
    }

    @PostConstruct
    void criarDiretorio() throws IOException {
        Files.createDirectories(Path.of(diretorio));
    }

    @Transactional
    public String salvar(MultipartFile arquivo, String baseUrl) {
        if (arquivo == null || arquivo.isEmpty()) {
            throw new RequisicaoInvalidaException("Envie um arquivo.");
        }
        if (arquivo.getSize() > TAMANHO_MAXIMO_BYTES) {
            throw new RequisicaoInvalidaException("Arquivo muito grande. Limite de 25 MB.");
        }

        String extensao = extensaoDe(arquivo.getOriginalFilename());
        boolean imagem = EXTENSOES_IMAGEM.contains(extensao);
        if (!imagem && !EXTENSOES_VIDEO.contains(extensao)) {
            throw new RequisicaoInvalidaException(
                    "Tipo de arquivo não aceito. Use imagem (png, jpg, gif, webp) ou vídeo (mp4, webm).");
        }

        String nomeGerado = UUID.randomUUID() + "." + extensao;
        Path destino = Path.of(diretorio, nomeGerado);

        try (InputStream entrada = arquivo.getInputStream()) {
            Files.copy(entrada, destino, StandardCopyOption.REPLACE_EXISTING);
        } catch (IOException e) {
            throw new IllegalStateException("Falha ao salvar o arquivo enviado.", e);
        }

        int[] dimensoes = imagem ? dimensoesDaImagem(destino) : null;
        String url = baseUrl + "/midia/" + nomeGerado;

        Midia midia = new Midia();
        midia.setNomeOriginal(truncar(arquivo.getOriginalFilename(), NOME_ORIGINAL_MAXIMO));
        midia.setNomeArquivo(nomeGerado);
        midia.setUrl(url);
        midia.setTipoMime(arquivo.getContentType() != null ? arquivo.getContentType() : "application/octet-stream");
        midia.setTamanhoBytes(arquivo.getSize());
        if (dimensoes != null) {
            midia.setLarguraPx(dimensoes[0]);
            midia.setAlturaPx(dimensoes[1]);
        }
        midiaDao.save(midia);

        return url;
    }

    private static int[] dimensoesDaImagem(Path arquivo) {
        try {
            BufferedImage imagem = ImageIO.read(arquivo.toFile());
            return imagem == null ? null : new int[] { imagem.getWidth(), imagem.getHeight() };
        } catch (IOException e) {
            return null;
        }
    }

    private static String extensaoDe(String nomeOriginal) {
        if (nomeOriginal == null || !nomeOriginal.contains(".")) {
            return "";
        }
        return nomeOriginal.substring(nomeOriginal.lastIndexOf('.') + 1).toLowerCase();
    }

    private static String truncar(String valor, int maximo) {
        if (valor == null || valor.isBlank()) {
            return "arquivo";
        }
        return valor.length() > maximo ? valor.substring(0, maximo) : valor;
    }
}
