# MINHA SAÚDE FEMININA
> Um aplicativo pensado para cuidar da mulher em todas as fases da vida.
Uma parceria entre os cursos de Medicina e Sistemas de Informação.
<br></br>
## 👩‍💻 Autores

- [Alexandre Santos Diniz ](https://github.com/Alexandredinizx)
- [Felipe Derengoski Fernandes](https://github.com/felipe-fee)
- [Giovana Schmitt](https://github.com/giovanaschmitt)
- [Gustavo Da Silva Cavalheiro Nogueira](https://github.com/GustavoCavalheiro)
- [Taison Pedrini](https://github.com/TaisonPedrini)
- [Vinícius Mayer Rover](https://github.com/viniciusmrover)
<br></br>
## 1. 🎯 OBJETIVO
   
  <p>O objetivo do aplicativo é promover o acesso à informação e ao acompanhamento da saúde da mulher por meio de uma solução tecnológica acessível, oferecendo conteúdos educativos, orientações preventivas e ferramentas de monitoramento de sinais e sintomas. </p> 
   <p> Destacamos que a aplicação não se trata de um substituto ao atendimento profissional em saúde, mas como um recurso complementar, com objetivo de auxiliar o usuário no reconhecimento de sinais de alerta, no acompanhamento de sua saúde e incentivando a busca por atendimento qualificado junto à UBS (Unidade Básica de Saúde).</p><br>
   
## 2. 📲 TELAS
`LOGIN`
`CADASTRO`
`HOME`
`HOJE`
`CICLO`
`SINTOMAS`
`CONTEÚDO`
`CONTEÚDO DETALHADO`
`PERFIL`
`CONFIGURAÇÕES`
   <br></br>
   
## 3. 💻 TECNOLOGIAS ESCOLHIDAS
   
   #### 3.1 Camada de Cliente (Front-end Mobile)
   - Framework: Flutter (Google).
   - Linguagem: Dart.
   - Gerenciamento de Estado: Provider.
   - Comunicação: Cliente HTTP consumindo API REST via JSON.
   - Persistência Local (Cache): Hive (para dados básicos offline).
<br></br>
   #### 3.2 Segmento Administrativo (Web) <br>
   - Interface Web: Desenvolvida com HTML5, CSS3 e JavaScript, utilizando como base principal para o desenvolvimento web o framework Bootstrap 5.
   - Persistência Local (Cache): Local storage.
<br></br>
   #### 3.3 Camada de Segurança e Identidade (Cloud)
   - Provedor: Firebase (Google Cloud).
   - Serviço de Auth: Firebase Authentication (E-mail/Senha).
   - Notificações: Firebase Cloud Messaging (FCM) para alertas de ciclo e saúde.
   - Integração: O App recebe um ID Token (JWT) que é repassado ao Backend Java para validação.
<br></br>
   #### 3.4 Camada de Processamento (Backend API)
   - Linguagem: Java 17+ (LTS).
   - Framework: Spring Boot 3.x.
   - Segurança: Spring Security integrado ao Firebase Admin SDK.
   - Persistência: Spring Data JPA (Hibernate) para abstração de queries SQL.
   - Documentação: OpenAPI 3.0 (Auto-gerada para testes de endpoint).
<br></br>
   #### 3.5 Camada de Dados e Performance (Persistência)
   - RDBMS (Relacional): Oracle Database 19c (19.27c) sem Oracle Grid Infrastructure (GI).
   - NoSQL / In-Memory (Cache): Redis.
<br></br>

## 4. 📁 ESTRUTURA RAIZ
```bash
 /Minha-saude-feminina
│
├── admin/web/              
│   # Aplicação web responsável pelo painel administrativo do sistema,
│   # permitindo gerenciamento de usuários, conteúdos e informações.
│
├── backend/                
│   # API e regras de negócio da aplicação, responsável pela comunicação
│   # com o banco de dados, autenticação e processamento das funcionalidades.
│
├── frontend/mobile         
│   # Aplicação mobile voltada ao usuário final, contendo a interface gráfica,
│   # funcionalidades de navegação e interação com o sistema.
│
├── .env.example            
│   # Arquivo modelo das variáveis de ambiente necessárias para execução
│   # do projeto, sem expor dados sensíveis.
│
├── .gitignore              
│   # Arquivo utilizado pelo Git para definir quais arquivos e diretórios
│   # não devem ser enviados ao repositório.
│
├── docker-compose.yml      
│   # Arquivo de configuração do Docker Compose utilizado para definir
│   # e executar múltiplos containers da aplicação de forma automatizada.
│
└── README.md               
    # Documentação principal do projeto contendo instruções,
    # tecnologias utilizadas e informações gerais do sistema.
```
