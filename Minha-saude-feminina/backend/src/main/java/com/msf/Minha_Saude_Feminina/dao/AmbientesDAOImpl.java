package com.complexo.UNIFEBE_Complexo_Esportivo.dao;

import com.complexo.UNIFEBE_Complexo_Esportivo.controller.CredenciaisBanco;

import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;

public class AmbientesDAOImpl implements IAmbientesDAOImpl {

    // Atributos
    private Statement s = null;

    public AmbientesDAOImpl() {
        CredenciaisBanco credencial = new CredenciaisBanco();
        ConexaoDB db = new ConexaoDB(
                credencial.getIP(),
                credencial.getDatabase(),
                credencial.getUser(),
                credencial.getPwd_banco()
        );
        this.s = db.getS();
    }

    // Inserir um registro de ambiente
    @Override
    public int inserirAmbiente(Ambientes ambiente) {
        int linhasAfetadas = 0;

        try {
            String SQL = "INSERT INTO sisagenda.ambientes (id_AMBIENTES, Nome_Ambiente, Descricao) " +
                    "VALUES (" +
                    "sisagenda.increment_ambientes.nextval, '" +
                    ambiente.getNome_ambiente() + "', '" +
                    ambiente.getDescricao() + "')";
            linhasAfetadas = this.s.executeUpdate(SQL);
            System.out.println("Ambiente inserido com sucesso: " + linhasAfetadas + " linha(s)");
        } catch (Exception e) {
            System.out.println("Erro ao inserir ambiente: " + e.getMessage());
            e.printStackTrace();
        }
        return linhasAfetadas;
    }

    // Remover um registro de ambiente
    @Override
    public int removerAmbiente(Ambientes ambiente) {
        int linhasAfetadas = 0;

        try {
            String SQL = "DELETE sisagenda.ambientes " +
                    "WHERE id_AMBIENTES = " + ambiente.getId_AMBIENTES();
            linhasAfetadas = this.s.executeUpdate(SQL);
            System.out.println("Ambiente removido com sucesso: " + linhasAfetadas + " linha(s)");
        } catch (Exception e) {
            System.out.println("Erro ao remover ambiente: " + e.getMessage());
            e.printStackTrace();
        }
        return linhasAfetadas;
    }

    // Atualizar um registro de ambiente
    @Override
    public int atualizarAmbiente(Ambientes ambiente) {
        int linhasAfetadas = 0;

        try {
            String SQL = "UPDATE sisagenda.ambientes " +
                    "SET " +
                    "Nome_Ambiente = " + "'" + ambiente.getNome_ambiente() + "'," +
                    "Descricao = " + "'" + ambiente.getDescricao() + "'" +
                    "WHERE id_AMBIENTES = " + ambiente.getId_AMBIENTES();
            linhasAfetadas = this.s.executeUpdate(SQL);
            System.out.println("Ambiente alterado com sucesso: " + linhasAfetadas + " linha(s)");
        } catch (Exception e) {
            System.out.println("Erro ao alterar ambiente: " + e.getMessage());
            e.printStackTrace();
        }
        return linhasAfetadas;
    }


    // Consultar ambientes registrados
    @Override
    public ArrayList<Ambientes> consultarAmbientes() {
        ArrayList<Ambientes> lista = new ArrayList<>();
        try {
            String SQL = "SELECT * FROM sisagenda.ambientes ORDER BY Nome_ambiente";
            ResultSet rset = s.executeQuery(SQL);

            while (rset.next()) {
                Ambientes ambiente = new Ambientes();
                ambiente.setId_AMBIENTES(rset.getInt("id_AMBIENTES"));
                ambiente.setNome_ambiente(rset.getString("Nome_ambiente"));
                ambiente.setDescricao(rset.getString("Descricao"));
                lista.add(ambiente);
            }
        } catch (Exception e) {
            System.out.println("Erro ao os ambientes: " + e.getMessage());
            e.printStackTrace();
        }
        return lista;
    }

    // Consultar ambiente por nome
    @Override
    public ArrayList<Ambientes> buscarAmbientePorNome(String nome) {
        ArrayList<Ambientes> lista = new ArrayList<>();

        try {
            String SQL = "SELECT * FROM sisagenda.ambientes WHERE Nome_ambiente LIKE '%" + nome + "%' ORDER BY Nome_ambiente";
            ResultSet rset = s.executeQuery(SQL);

            while (rset.next()) {
                Ambientes ambiente = new Ambientes();
                ambiente.setId_AMBIENTES(rset.getInt("id_AMBIENTES"));
                ambiente.setNome_ambiente(rset.getString("Nome_ambiente"));
                ambiente.setDescricao(rset.getString("Descricao"));
                lista.add(ambiente);
            }
        } catch (Exception e) {
            System.out.println("Erro ao buscar ambiente: " + e.getMessage());
            e.printStackTrace();
        }
        return lista;
    }

}
