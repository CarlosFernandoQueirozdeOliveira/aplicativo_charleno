# Gestão Acadêmica - Trabalho Charchar

Este projeto é uma aplicação de gestão acadêmica composta por um backend em FastAPI e um frontend em Flutter.

## 📋 Pré-requisitos

Para rodar o projeto, você precisará de:

- **Docker Desktop** (Recomendado para rodar o backend/banco de dados facilmente)
- **Flutter SDK** (Para o frontend)
- **Git**

---

## 🚀 Passo a Passo para Rodar

### 1. Backend (API + Banco de Dados)

A maneira mais fácil de rodar o backend é usando Docker Compose.

1. Abra o terminal na pasta `api/api_gerenciamento_de_tarefas`:
   ```bash
   cd api/api_gerenciamento_de_tarefas
   ```

2. Suba os containers (API e Banco de Dados):
   ```bash
   docker-compose up -d --build
   ```
   
   *Isso vai baixar o PostgreSQL, configurar o banco, e iniciar a API em `http://localhost:8000`.*

3. Verifique se está rodando:
   Abra no navegador: [http://localhost:8000/docs](http://localhost:8000/docs) (Deve aparecer a documentação Swagger).

---

### 2. Frontend (App Flutter)

O Flutter precisa saber onde está a API. Para isso, usamos um parâmetro especial ao iniciar.

1. Volte para a raiz do projeto (onde está este README):
   ```bash
   cd ../..
   ```
   *(Ou apenas abra um novo terminal na pasta raiz `trabalho_charchar`)*

2. Instale as dependências:
   ```bash
   flutter pub get
   ```

3. **Inicie o aplicativo** (Comando IMPORTANTE):
   
   Execute este comando exato para garantir que o app conecte na API local:

   ```bash
   flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000/api/v1
   ```
   
   *Se estiver usando emulador Android, use `10.0.2.2` em vez de `localhost`.*

---

## 🔑 Credenciais de Acesso

Use estas credenciais para testar o sistema:

- **Email:** `teste@universidade.edu`
- **Senha:** `senha12345`

---

## ⚠️ Solução de Problemas Comuns

**Erro: Connection Timeout / Não conecta na API**
- Certifique-se de que usou o comando com `--dart-define=API_BASE_URL=...` acima.
- Verifique se o Docker está rodando e a API está acessível em `localhost:8000`.

**Erro: "Pending" tasks aparecendo em "Em Andamento"**
- O sistema considera "Em Andamento" qualquer tarefa que **ainda está no prazo** de entrega.
- "Atrasadas" (antigo Pendentes) mostra apenas tarefas que **já venceram** a data de entrega.
