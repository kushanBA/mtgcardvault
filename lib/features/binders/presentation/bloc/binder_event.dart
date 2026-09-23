import 'package:equatable/equatable.dart';

sealed class BinderEvent extends Equatable {
  const BinderEvent();

  @override
  List<Object?> get props => [];
}

class LoadMyBinders extends BinderEvent {
  const LoadMyBinders();
}

class LoadBinderDetail extends BinderEvent {
  final String id;
  const LoadBinderDetail(this.id);

  @override
  List<Object?> get props => [id];
}

class LoadPublicBinders extends BinderEvent {
  const LoadPublicBinders();
}

class LoadCardBinderNames extends BinderEvent {
  const LoadCardBinderNames();
}
