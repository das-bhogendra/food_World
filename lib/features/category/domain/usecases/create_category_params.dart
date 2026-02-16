import 'package:equatable/equatable.dart';

class CreateCategoryParams extends Equatable {
  final String name;
  final String? description;
  final String addedBy;

  const CreateCategoryParams({
    required this.name,
    this.description,
    required this.addedBy,
  });

  @override
  List<Object?> get props => [name, description, addedBy];
}
