package com.complexo.UNIFEBE_Complexo_Esportivo.dao;

import com.complexo.UNIFEBE_Complexo_Esportivo.controller.CredenciaisBanco;

import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;

public class UsuarioDAOImpl implements IUsuarioDAOImpl {

    // Atributos
    private Statement s = null;

    public UsuarioDAOImpl() {
        CredenciaisBanco credencial = new CredenciaisBanco();
        ConexaoDB db = new ConexaoDB(
                credencial.getIP(),
                credencial.getDatabase(),
                credencial.getUser(),
                credencial.getPwd_banco()
        );
        this.s = db.getS();
    }


    // Inserir um novo usuário
    @Override
    public int inserirUsuario(Usuario usuario) {
        int linhasAfetadas = 0;

        try {
            String SQL = "INSERT INTO sisagenda.usuario (id_USUARIO, Nome, Matricula, Senha, Tipo) " +
                    "VALUES (sisagenda.increment_usuario.nextval, '" +
                    usuario.getNome() + "', " +
                    usuario.getMatricula() + ", '" +
                    usuario.getSenha() + "', '" +
                    usuario.getTipo() + "')";
            linhasAfetadas = this.s.executeUpdate(SQL);
            System.out.println("Usuário Inserido com sucesso: " + linhasAfetadas + " linha(s)");
        } catch (Exception e) {
            System.out.println("Erro ao inserir usuário: " + e.getMessage());
            e.printStackTrace();
        }
        return linhasAfetadas;
    }

    // Remover um usuário por matrícula
    @Override
    public int removerUsuarioPorMaticula(Usuario usuario) {
        int linhasAfetadas = 0;

        try {
            String SQL = "DELETE sisagenda.usuario " +
                    "WHERE matricula = " + usuario.getMatricula();
            linhasAfetadas = this.s.executeUpdate(SQL);
            System.out.println("Usuário removido com sucesso: " + linhasAfetadas + " linha(s)");
        } catch (Exception e) {
            System.out.println("Erro ao remover usuário: " + e.getMessage());
            e.printStackTrace();
        }
        return linhasAfetadas;
    }

    // Buscar usuário por matrícula
    @Override
    public Usuario buscarUsuarioPorMatricula(int matricula) {
        Usuario usuario = null;

        try {
            String SQL = "SELECT * FROM sisagenda.usuario WHERE Matricula = " + matricula;
            ResultSet rset = s.executeQuery(SQL);

            if (rset.next()) {
                usuario = new Usuario();
                usuario.setId_USUARIO(rset.getInt("Id_USUARIO"));
                usuario.setNome(rset.getString("Nome"));
                usuario.setSenha(rset.getString("Senha"));
                usuario.setMatricula(rset.getInt("Matricula"));
                usuario.setTipo(rset.getString("Tipo").charAt(0));
            }
        } catch (Exception e) {
            System.out.println("Erro ao buscar usuário: " + e.getMessage());
            e.printStackTrace();
        }

        return usuario;
    }


    // Consultar usuário por nome
    @Override
    public ArrayList<Usuario> buscarUsuarioPorNome(String nome) {
        ArrayList<Usuario> lista = new ArrayList<>();

        try {
            String SQL = "SELECT * FROM sisagenda.usuario WHERE Nome LIKE '%" + nome + "%'";
            ResultSet rset = s.executeQuery(SQL);

            while (rset.next()) {
                Usuario usuario = new Usuario();
                usuario.setNome(rset.getString("Nome"));
                usuario.setSenha(rset.getString("Senha"));
                usuario.setMatricula(rset.getInt("Matricula"));
                usuario.setTipo(rset.getString("Tipo").charAt(0));
                lista.add(usuario);
            }
        } catch (Exception e) {
            System.out.println("Erro ao buscar usuário: " + e.getMessage());
            e.printStackTrace();
        }
        return lista;
    }

    // Consultar todos os usuários
    @Override
    public ArrayList<Usuario> selectUsuarios() {
        ArrayList<Usuario> lista = new ArrayList<>();

        try {
            String SQL = "SELECT * FROM sisagenda.usuario";
            ResultSet rset = s.executeQuery(SQL);

            while (rset.next()) {
                Usuario usuario = new Usuario();
                usuario.setNome(rset.getString("Nome"));
                usuario.setSenha(rset.getString("Senha"));
                usuario.setMatricula(rset.getInt("Matricula"));
                usuario.setTipo(rset.getString("Tipo").charAt(0));
                lista.add(usuario);
            }
        } catch (Exception e) {
            System.out.println("Erro ao buscar usuários: " + e.getMessage());
            e.printStackTrace();
        }
        return lista;
    }
}