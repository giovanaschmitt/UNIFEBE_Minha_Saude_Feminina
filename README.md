# MINHA SAUDE FEMININA
Um aplicativo pensado para cuidar da mulher em todas as fases da vida.
Uma parceria entre os cursos de Medicina e Sistemas de Informação.

------------------------------------------------------------------------------------------------------------------------------------------------------------
Autores: Alexandre Santos Diniz, Felipe Derengoski Fernandes, Giovana Schmitt, Gustavo Da Silva Cavalheiro Nogueira, Taison Pedrini e Vinícius Mayer Rover.

------------------------------------------------------------------------------------------------------------------------------------------------------------

1. OBJETIVO
   
   O objetivo do aplicativo é promover o acesso à informação e ao acompanhamento da saúde da mulher por meio de uma solução tecnológica acessível, oferecendo conteúdos educativos, orientações preventivas e ferramentas de monitoramento de sinais e sintomas.
   
    Destacamos que a aplicação não se trata de um substituto ao atendimento profissional em saúde, mas como um recurso complementar, com objetivo de auxiliar o usuário no reconhecimento de sinais de alerta, no acompanhamento de sua saúde e incentivando a busca por atendimento qualificado junto à UBS (Unidade Básica de Saúde).

3. FUNCIONALIDADES
4. TECNOLOGIAS ESCOLHIDAS
   
   3.1 Camada de Cliente (Front-end Mobile)
    - Framework: Flutter (Google).
    - Linguagem: Dart.
    - Gerenciamento de Estado: Provider.
    - Comunicação: Cliente HTTP consumindo API REST via JSON.
    - Persistência Local (Cache): Hive (para dados básicos offline).


   3.2 Segmento Administrativo (Web)
    - Interface Web: Desenvolvida com HTML5, CSS3 e JavaScript, utilizando como base principal para o desenvolvimento web o framework Bootstrap 5.
    - Persistência Local (Cache): Local storage.


   3.3 Camada de Segurança e Identidade (Cloud)
    - Provedor: Firebase (Google Cloud).
    - Serviço de Auth: Firebase Authentication (E-mail/Senha).
    - Notificações: Firebase Cloud Messaging (FCM) para alertas de ciclo e saúde.
    - Integração: O App recebe um ID Token (JWT) que é repassado ao Backend Java para validação.

   3.4 Camada de Processamento (Backend API)
   - Linguagem: Java 17+ (LTS).
   - Framework: Spring Boot 3.x.
   - Segurança: Spring Security integrado ao Firebase Admin SDK.
   - Persistência: Spring Data JPA (Hibernate) para abstração de queries SQL.
   - Documentação: OpenAPI 3.0 (Auto-gerada para testes de endpoint).

   3.5 Camada de Dados e Performance (Persistência)
   - RDBMS (Relacional): Oracle Database 19c (19.27c) sem Oracle Grid Infrastructure (GI).
     + Papel: Armazenamento transacional de ciclos, sintomas e dados sensíveis da LGPD.
   - NoSQL / In-Memory (Cache): Redis.
     + Papel: Cache de sessões, resultados de consultas pesadas e controle de tráfego (Rate Limit).

   3.6 Infraestrutura e Orquestração
      - Sistema Operacional Host: Oracle Linux 9.7.
      - Virtualização: Docker e Docker Compose.
      - Load Balancer / Reverse Proxy: Nginx (Containerizado).
      - Estratégia de Escalonamento: 2 instâncias da API Spring Boot em Round Robin.
  
    3.6.1 Detalhamento de Hardware (Host Local)
      - Processador: 4 Núcleos Físicos    
      - Memória RAM: 8 GB (Física)
      - Memória SWAP: 8 GB (Virtual)
      - Armazenamento: 200 GB
      
    3.6.2 Distribuição dos recursos do Host Local
     - Oracle Linux (Host): 1.0 GB / Destinada ao kernel e processos do Docker.
     - Oracle 19c: 3.5 GB / SGA (2.5 Gb) + PGA (1 Gb)
     - Java Spring Boot (2x Docker): 2.0 GB / 1 GB para cada instância (Xms512m / Xmx1g).
     - Redis: 256 MB / Destinado a cache de texto
     - Nginx: 64 MB / Alta densidade de conexões com baixo consumo via Event-Loop. Atuará como Proxy Reverso também para o tráfego Web, diferenciando requisições de API (/api/**) de requisições administrativas (/admin/**)
     - Margem de  Segurança: ~1.2 GB / Essencial para evitar o uso excessivo de SWAP.


5. ESTRUTURA DE PASTAS
