import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({
    super.key,
    this.onAuthenticated,
  });

  final VoidCallback? onAuthenticated;

  @override
  State<AuthScreen> createState() =>
      _AuthScreenState();
}

class _AuthScreenState
    extends State<AuthScreen> {
final _formKey =
GlobalKey<FormState>();

final _nameController =
TextEditingController();

final _emailController =
TextEditingController();

final _phoneController =
TextEditingController();

final _addressController =
TextEditingController();

final _passwordController =
TextEditingController();

bool _isLogin = true;
bool _isLoading = false;
bool _obscurePassword = true;

@override
void dispose() {
_nameController.dispose();
_emailController.dispose();
_phoneController.dispose();
_addressController.dispose();
_passwordController.dispose();

super.dispose();
}

// =========================================================
// GİRİŞ / KAYIT
// =========================================================

Future<void> _submit() async {
if (!_formKey.currentState!.validate()) {
return;
}

setState(() {
_isLoading = true;
});

try {
final Map<String, dynamic> result;

if (_isLogin) {
result =
await AuthService.login(
email:
_emailController.text.trim(),
password:
_passwordController.text,
);
} else {
result =
await AuthService.register(
name:
_nameController.text.trim(),
email:
_emailController.text.trim(),
phone:
_phoneController.text.trim(),
address:
_addressController.text.trim(),
password:
_passwordController.text,
);
}

if (!mounted) {
return;
}

if (result['success'] == true) {
ScaffoldMessenger.of(context)
.showSnackBar(
SnackBar(
content: Text(
_isLogin
? 'Giriş başarılı.'
: 'Hesabınız başarıyla oluşturuldu.',
),
backgroundColor:
const Color(0xFF10B981),
),
);

widget.onAuthenticated?.call();

Navigator.of(context).pop(true);

return;
}

_showError(
(
result['error'] ??
result['message'] ??
'İşlem gerçekleştirilemedi.'
).toString(),
);
} catch (error) {
if (!mounted) {
return;
}

_showError(
error
.toString()
.replaceFirst(
'Exception: ',
'',
),
);
} finally {
if (mounted) {
setState(() {
_isLoading = false;
});
}
}
}

void _showError(
String message,
) {
ScaffoldMessenger.of(context)
.showSnackBar(
SnackBar(
content: Text(message),
backgroundColor:
const Color(0xFFEF4444),
),
);
}

void _changeMode() {
setState(() {
_isLogin = !_isLogin;
});

_formKey.currentState?.reset();
}
@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor:
AppTheme.darkTheme.scaffoldBackgroundColor,
appBar: AppBar(
backgroundColor: Colors.transparent,
elevation: 0,
leading: IconButton(
onPressed: () =>
Navigator.of(context).pop(false),
icon: const Icon(
Icons.close_rounded,
),
),
),
body: SafeArea(
child: Center(
child: SingleChildScrollView(
padding:
const EdgeInsets.fromLTRB(
24,
12,
24,
32,
),
child: ConstrainedBox(
constraints:
const BoxConstraints(
maxWidth: 430,
),
child: Form(
key: _formKey,
child: Column(
crossAxisAlignment:
CrossAxisAlignment.stretch,
children: [
Center(
child: Container(
width: 82,
height: 82,
padding:
const EdgeInsets.all(
12,
),
decoration:
BoxDecoration(
color:
const Color(
0xFF101D31,
),
borderRadius:
BorderRadius.circular(
24,
),
border: Border.all(
color:
const Color(
0xFF233754,
),
),
),
child: Image.asset(
'assets/images/notla_logo.png',
fit: BoxFit.contain,
),
),
),

const SizedBox(
height: 24,
),

Text(
_isLogin
? 'Tekrar hoş geldin'
: 'Notla’ya katıl',
textAlign:
TextAlign.center,
style:
const TextStyle(
color: Colors.white,
fontSize: 27,
fontWeight:
FontWeight.w800,
),
),

const SizedBox(
height: 8,
),

Text(
_isLogin
? 'Not satın almak, indirmek ve yüklemek için giriş yap.'
: 'Ders notlarını paylaşmak ve satın almak için hesabını oluştur.',
textAlign:
TextAlign.center,
style:
const TextStyle(
color:
Color(
0xFF94A3B8,
),
fontSize: 14,
height: 1.45,
),
),

const SizedBox(
height: 30,
),

if (!_isLogin) ...[
_buildField(
controller:
_nameController,
label: 'Ad soyad',
hint:
'Adınızı ve soyadınızı girin',
icon:
Icons.person_outline_rounded,
textInputAction:
TextInputAction.next,
validator: (value) {
if (
value == null ||
value
.trim()
.length <
2
) {
return 'Ad soyad en az 2 karakter olmalıdır.';
}

return null;
},
),

const SizedBox(
height: 16,
),
],

_buildField(
controller:
_emailController,
label: 'E-posta',
hint:
'ornek@email.com',
icon:
Icons.mail_outline_rounded,
keyboardType:
TextInputType
.emailAddress,
textInputAction:
TextInputAction.next,
validator: (value) {
final String email =
value
?.trim() ??
'';

if (
email.isEmpty ||
!RegExp(
r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
).hasMatch(
email,
)
) {
return 'Geçerli bir e-posta adresi girin.';
}

return null;
},
),

const SizedBox(
height: 16,
),

if (!_isLogin) ...[
_buildField(
controller:
_phoneController,
label:
'Telefon numarası',
hint:
'5XXXXXXXXX',
icon:
Icons.phone_outlined,
keyboardType:
TextInputType.phone,
textInputAction:
TextInputAction.next,
validator: (value) {
final String phone =
value
?.trim() ??
'';

final String digits =
phone.replaceAll(
RegExp(
r'[^0-9]',
),
'',
);

if (
digits.length <
10 ||
digits.length >
15
) {
return 'Geçerli bir telefon numarası girin.';
}

return null;
},
),

const SizedBox(
height: 16,
),

_buildField(
controller:
_addressController,
label:
'Ödeme adresi',
hint:
'İl / İlçe / Adres',
icon:
Icons.location_on_outlined,
textInputAction:
TextInputAction.next,
validator: (value) {
final String address =
value
?.trim() ??
'';

if (
address.length <
3
) {
return 'Adres bilgisi girin.';
}

return null;
},
),

const SizedBox(
height: 16,
),
],

_buildField(
controller:
_passwordController,
label: 'Şifre',
hint:
'En az 6 karakter',
icon:
Icons.lock_outline_rounded,
obscureText:
_obscurePassword,
textInputAction:
TextInputAction.done,
onSubmitted:
(_) => _submit(),
suffixIcon:
IconButton(
onPressed: () {
setState(() {
_obscurePassword =
!_obscurePassword;
});
},
icon: Icon(
_obscurePassword
? Icons
.visibility_off_outlined
: Icons
.visibility_outlined,
color:
const Color(
0xFF94A3B8,
),
),
),
validator: (value) {
if (
value == null ||
value.length < 6
) {
return 'Şifre en az 6 karakter olmalıdır.';
}

return null;
},
),

const SizedBox(
height: 24,
),

SizedBox(
height: 54,
child:
ElevatedButton(
onPressed:
_isLoading
? null
: _submit,
style:
ElevatedButton
.styleFrom(
backgroundColor:
const Color(
0xFF168CFF,
),
foregroundColor:
Colors.white,
disabledBackgroundColor:
const Color(
0xFF168CFF,
).withOpacity(
0.55,
),
shape:
RoundedRectangleBorder(
borderRadius:
BorderRadius
.circular(
16,
),
),
),
child:
_isLoading
? const SizedBox(
width: 23,
height: 23,
child:
CircularProgressIndicator(
strokeWidth:
2.5,
color:
Colors
.white,
),
)
: Text(
_isLogin
? 'Giriş Yap'
: 'Hesap Oluştur',
style:
const TextStyle(
fontSize:
16,
fontWeight:
FontWeight
.w700,
),
),
),
),
  const SizedBox(
    height: 14,
  ),

  TextButton(
    onPressed:
    _isLoading
        ? null
        : _changeMode,
    child: Text.rich(
      TextSpan(
        text:
        _isLogin
            ? 'Henüz hesabın yok mu? '
            : 'Zaten hesabın var mı? ',
        style:
        const TextStyle(
          color:
          Color(
            0xFF94A3B8,
          ),
        ),
        children: [
          TextSpan(
            text:
            _isLogin
                ? 'Kayıt Ol'
                : 'Giriş Yap',
            style:
            const TextStyle(
              color:
              Color(
                0xFF38BDF8,
              ),
              fontWeight:
              FontWeight.w700,
            ),
          ),
        ],
      ),
    ),
  ),

  const SizedBox(
    height: 8,
  ),

  const Text(
    'Giriş yapmadan ders notlarını incelemeye devam edebilirsin.',
    textAlign:
    TextAlign.center,
    style: TextStyle(
      color:
      Color(
        0xFF64748B,
      ),
      fontSize: 12,
    ),
  ),
],
),
),
),
),
),
),
);
}

  // =========================================================
  // ORTAK FORM ALANI
  // =========================================================

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    bool obscureText = false,
    Widget? suffixIcon,
    void Function(String)? onSubmitted,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      onFieldSubmitted: onSubmitted,
      validator: validator,
      style:
      const TextStyle(
        color: Colors.white,
      ),
      decoration:
      InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(
          icon,
          color:
          const Color(
            0xFF38BDF8,
          ),
        ),
        suffixIcon: suffixIcon,
        labelStyle:
        const TextStyle(
          color:
          Color(
            0xFF94A3B8,
          ),
        ),
        hintStyle:
        const TextStyle(
          color:
          Color(
            0xFF64748B,
          ),
        ),
        filled: true,
        fillColor:
        const Color(
          0xFF0E1B2D,
        ),
        border:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(
            16,
          ),
          borderSide:
          const BorderSide(
            color:
            Color(
              0xFF243853,
            ),
          ),
        ),
        enabledBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(
            16,
          ),
          borderSide:
          const BorderSide(
            color:
            Color(
              0xFF243853,
            ),
          ),
        ),
        focusedBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(
            16,
          ),
          borderSide:
          const BorderSide(
            color:
            Color(
              0xFF38BDF8,
            ),
            width: 1.5,
          ),
        ),
        errorBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(
            16,
          ),
          borderSide:
          const BorderSide(
            color:
            Color(
              0xFFEF4444,
            ),
          ),
        ),
      ),
    );
  }
}