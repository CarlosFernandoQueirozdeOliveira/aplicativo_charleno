"""Rotas de Autenticação."""
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from passlib.hash import bcrypt
from database import get_db
from app.models import Aluno
from app.schemas import LoginRequest, Token

router = APIRouter(prefix="/auth", tags=["Auth"])

def verify_password(plain_password: str, hashed_password: str) -> bool:
    return bcrypt.verify(plain_password, hashed_password)

@router.post("/login", response_model=Token)
def login_for_access_token(form_data: LoginRequest, db: Session = Depends(get_db)):
    """Realiza login de aluno e retorna token de acesso."""
    # Buscar aluno por email
    aluno = db.query(Aluno).filter(Aluno.email == form_data.email).first()
    
    # Verificar credenciais
    if not aluno or not verify_password(form_data.password, aluno.senha_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Email ou senha incorretos",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    # Gerar token (aqui usando implementação simples, em produção usar JWT real)
    # Como o Auth Service do Flutter só armazena e envia de volta, não precisamos validar a assinatura aqui
    # a menos que implementemos rotas protegidas que decodifiquem o token.
    # Vamos gerar um token que inclua o ID do aluno para uso futuro se necessário
    
    token = f"fake-jwt-token-for-{aluno.id}"
    
    return {
        "access_token": token, 
        "token_type": "bearer",
        "user_id": aluno.id,
        "user_name": aluno.nome,
        "user_email": aluno.email
    }
