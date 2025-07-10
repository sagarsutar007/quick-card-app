import 'package:quickcard/features/schools/data/models/authority_request_model.dart';

abstract class AddAuthorityEvent {}

class SubmitAuthorityEvent extends AddAuthorityEvent {
  final int schoolId;
  final AuthorityRequestModel model;

  SubmitAuthorityEvent(this.schoolId, this.model);
}
