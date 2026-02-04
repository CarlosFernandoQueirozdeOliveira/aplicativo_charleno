
import 'package:equatable/equatable.dart';

class ApiException extends Equatable implements Exception {
  final String message;
  final int? statusCode;

  const ApiException({required this.message, this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
  
  @override
  String toString() => 'ApiException(message: $message, statusCode: $statusCode)';
}

class ApiNotConfiguredException extends ApiException {
  const ApiNotConfiguredException() 
      : super(message: 'API não configurada / offline');
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException() : super(message: 'Não autorizado', statusCode: 401);
}

class ServerException extends ApiException {
  const ServerException({String? message}) 
      : super(message: message ?? 'Erro interno do servidor', statusCode: 500);
}
