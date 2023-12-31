import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';

import '../../../authentication/data/repository/validation_repo.dart';
import '../../data/repository/profile_repo.dart';

part 'edit_profile_event.dart';
part 'edit_profile_state.dart';

class EditProfileBloc extends Bloc<EditProfileEvent, EditProfileState> {
  String username = '';
  String displayName = '';
  String bio = '';

  ValidationRepo validationRepo = ValidationRepo();
  ProfileRepo profileRepo = ProfileRepo();

  EditProfileBloc() : super(EditProfileInitial()) {
    on<EditProfileUsernameChangedEvent>((event, emit) {
      bool validUsername = validationRepo.isValidUsername(event.username);
      if (validUsername) {
        emit(EditCanSubmit());
        username = event.username;
      } else {
        emit(EditProfileInitial());
      }
    });

    on<EditProfileDisplayNameChangedEvent>((event, emit) {
      displayName = event.name;
      emit(EditCanSubmit());
    });
    on<EditProfileBioChangedEvent>((event, emit) {
      bio = event.bio;
      emit(EditCanSubmit());
    });

    on<SubmitButtonPressedEvent>((event, emit) async {
      emit(EditProfileLoading());
      try {
        await profileRepo.updateProfile(
            event.username, event.displayName, event.bio);
        emit(EditProfileSuccess());
      } catch (e) {
        emit(EditProfileFailure(e.toString()));
      }
    });

    on<RequestEmailVerification>((event, emit) async {
      try {
        emit(EmailVerificationSending());
        await profileRepo.requestVerification(event.email);
        emit(EmailVerificationSent());
      } catch (e) {
        Logger logger = Logger();
        logger.e(e);
      }
    });

    void _handleImagePicker(event, emit) async {
      // Either the permission was already granted before or the user just granted it.
      late XFile? pickedImage;
      try {
        final ImagePicker imagePicker = ImagePicker();
        pickedImage = await imagePicker.pickImage(
          imageQuality: 60,
          preferredCameraDevice: CameraDevice.front,
          source: ImageSource.gallery,
        );
        if (pickedImage != null) {
          if (event is AvatarPickerButtonPressed) {
            try {
              emit(EditProfileLoading());
              await profileRepo.updateAvatarOrBanner(pickedImage, 'avatar');
              emit(AvatarUpdateSuccess());
              emit(EditProfileInitial());
            } catch (e) {
              emit(EditProfileFailure(e.toString()));
            }
          } else if (event is BannerPickerButtonPressed) {
            try {
              emit(EditProfileLoading());
              await profileRepo.updateAvatarOrBanner(pickedImage, 'banner');
              emit(BannerUpdateSuccess());

              emit(EditProfileInitial());
            } catch (e) {
              emit(EditProfileFailure(e.toString()));
            }
          }
        }
      } catch (e) {
        Logger logger = Logger();
        logger.e(e);
        emit(EditProfileFailure(e.toString()));
      }
    }

    on<AvatarPickerButtonPressed>(_handleImagePicker);
    on<BannerPickerButtonPressed>(_handleImagePicker);
  }
}
