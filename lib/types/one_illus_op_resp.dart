import 'package:artbooking/types/cloud_func_error.dart';
import 'package:artbooking/types/minimal_illustration_resp.dart';
import 'package:artbooking/types/user/partial_user.dart';
import 'package:cloud_functions/cloud_functions.dart';

class OneIllusOpResp {
  final bool success;
  final MinimalIllustrationResp illustration;
  final String message;
  final CloudFuncError error;
  final PartialUser user;

  OneIllusOpResp({
    required this.illustration,
    required this.success,
    this.message = '',
    required this.error,
    required this.user,
  });

  factory OneIllusOpResp.empty({bool success = false}) {
    return OneIllusOpResp(
      success: success,
      illustration: MinimalIllustrationResp.empty(),
      error: CloudFuncError.empty(),
      user: PartialUser.empty(),
    );
  }

  factory OneIllusOpResp.fromException(FirebaseFunctionsException exception) {
    return OneIllusOpResp(
      success: false,
      illustration: MinimalIllustrationResp.empty(),
      error: CloudFuncError.fromException(exception),
      user: PartialUser(),
    );
  }

  factory OneIllusOpResp.fromJSON(Map<dynamic, dynamic>? data) {
    if (data == null) {
      return OneIllusOpResp.empty();
    }

    return OneIllusOpResp(
      illustration: MinimalIllustrationResp.fromJSON(data['illustration']),
      success: data['success'] ?? true,
      user: PartialUser.fromJSON(data['user']),
      error: CloudFuncError.fromJSON(data['error']),
    );
  }

  factory OneIllusOpResp.fromMessage(String message) {
    return OneIllusOpResp(
      success: false,
      illustration: MinimalIllustrationResp.empty(),
      error: CloudFuncError.fromMessage(message),
      user: PartialUser(),
    );
  }
}
