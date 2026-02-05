"""Script para popular o banco de dados com dados de teste."""
import sys
from pathlib import Path

# Adicionar path para imports
sys.path.insert(0, str(Path(__file__).parent))

from datetime import datetime, timedelta
from passlib.hash import bcrypt
from sqlalchemy.orm import Session
from database import SessionLocal, create_tables
from app.models import Turma, Aluno, Disciplina, Professor, Tarefa, TipoTarefa, StatusTarefa


def seed_database():
    """Popula o banco com dados de teste de forma idempotente."""
    db: Session = SessionLocal()
    
    try:
        # Verificar se já existe seed
        existing_turma = db.query(Turma).filter(Turma.nome == "ADS 2024.1").first()
        if existing_turma:
            print("⚠️  Dados de seed já existem. Pulando...")
            print("✅ Seed data criado com sucesso!")
            return
        
        print("🌱 Populando banco de dados...")
        
        # 1. Criar Turma
        turma = Turma(nome="ADS 2024.1")
        db.add(turma)
        db.flush()  # Para obter o ID
        print(f"   ✓ Turma criada: {turma.nome} (ID: {turma.id})")
        
        # 2. Criar Aluno de teste
        aluno = Aluno(
            nome="Aluno Teste",
            email="teste@universidade.edu",
            senha_hash=bcrypt.hash("senha12345"),
            turma_id=turma.id
        )
        db.add(aluno)
        db.flush()
        print(f"   ✓ Aluno criado: {aluno.nome} / {aluno.email} (ID: {aluno.id})")
        
        # 3. Criar Disciplinas
        disciplinas = [
            Disciplina(nome="Cálculo I", codigo="MAT101"),
            Disciplina(nome="Programação Web", codigo="COMP201"),
        ]
        for d in disciplinas:
            db.add(d)
        db.flush()
        print(f"   ✓ {len(disciplinas)} disciplinas criadas")
        
        # 4. Criar Professores
        professores = [
            Professor(nome="Prof. Carlos Silva", email="carlos.silva@universidade.edu"),
            Professor(nome="Profa. Maria Santos", email="maria.santos@universidade.edu"),
        ]
        for p in professores:
            db.add(p)
        db.flush()
        print(f"   ✓ {len(professores)} professores criados")
        
        # 5. Criar Tarefas para o aluno
        tarefas = [
            Tarefa(
                aluno_id=aluno.id,
                tipo=TipoTarefa.ATIVIDADE,
                titulo="Lista de Exercícios - Derivadas",
                descricao="Resolver exercícios 1 a 15 do capítulo 3",
                disciplina_id=disciplinas[0].id,
                professor_id=professores[0].id,
                pontos=15,
                data_entrega=datetime.now() + timedelta(days=7),
                status=StatusTarefa.PENDENTE,
            ),
            Tarefa(
                aluno_id=aluno.id,
                tipo=TipoTarefa.PROJETO,
                titulo="Projeto Final - Sistema Web",
                descricao="Desenvolver uma aplicação web completa com CRUD",
                disciplina_id=disciplinas[1].id,
                professor_id=professores[1].id,
                pontos=40,
                data_entrega=datetime.now() + timedelta(days=30),
                status=StatusTarefa.EM_ANDAMENTO,
                iniciada_em=datetime.now() - timedelta(days=5),
            ),
        ]
        for t in tarefas:
            db.add(t)
        db.flush()
        print(f"   ✓ {len(tarefas)} tarefas criadas para o aluno")
        
        # Commit final
        db.commit()
        print("")
        print("=" * 50)
        print("✅ Seed data criado com sucesso!")
        print("=" * 50)
        print("")
        print("📝 Credenciais de teste:")
        print("   Email: teste@universidade.edu")
        print("   Senha: senha12345")
        print("")
        
    except Exception as e:
        db.rollback()
        print(f"❌ Erro ao criar seed: {e}")
        raise
    finally:
        db.close()


if __name__ == "__main__":
    # Garantir que as tabelas existem
    create_tables()
    seed_database()
