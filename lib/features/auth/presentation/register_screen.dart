import 'package:flutter/material.dart';
import 'package:gezdirelim/core/app_colors.dart';
import 'package:gezdirelim/core/supabase_service.dart';
import 'package:lucide_icons/lucide_icons.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  // KVKK / Consent state
  bool _kvkkAccepted = false;
  bool _consentAccepted = false;
  bool _kvkkOpened = false;
  bool _consentOpened = false;

  static const int _maxFieldLength = 50;

  void _handleRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final city = _cityController.text.trim();
    final district = _districtController.text.trim();

    // Validation
    if (name.isEmpty || email.isEmpty || password.isEmpty || city.isEmpty) {
      _showError('Lütfen tüm zorunlu alanları doldurun');
      return;
    }

    if (district.isEmpty) {
      _showError('Lütfen ilçe bilgisini girin');
      return;
    }

    if (password != confirmPassword) {
      _showError('Şifreler eşleşmiyor!');
      return;
    }

    if (password.length < 6) {
      _showError('Şifre en az 6 karakter olmalıdır');
      return;
    }

    if (!_kvkkAccepted) {
      _showError('KVKK Sözleşmesini kabul etmelisiniz');
      return;
    }

    if (!_consentAccepted) {
      _showError('Açık Rıza Metnini kabul etmelisiniz');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await SupabaseService.instance.signUp(
        email,
        password,
        data: {
          'display_name': name,
          'city': city,
          'district': district,
        },
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kayıt başarılı! Lütfen e-postanızı doğrulayın.'),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      _showError('Hata: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(LucideIcons.alertCircle, color: AppColors.error, size: 18),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  void _showKvkkSheet() {
    setState(() => _kvkkOpened = true);
    _showLegalSheet(
      title: 'KVKK Aydınlatma Metni',
      content: _kvkkDummyText,
    );
  }

  void _showConsentSheet() {
    setState(() => _consentOpened = true);
    _showLegalSheet(
      title: 'Açık Rıza Metni',
      content: _consentDummyText,
    );
  }

  void _showLegalSheet({required String title, required String content}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.surfaceBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(LucideIcons.shield, color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(LucideIcons.x, color: AppColors.textMuted, size: 20),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Divider(color: AppColors.surfaceBorder, height: 1),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    content,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      height: 1.7,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCityFilled = _cityController.text.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Yeni Hesap Oluştur',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Aramıza şimdi katıl.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
              ),
              const SizedBox(height: 40),

              // Ad Soyad
              _buildTextField(
                controller: _nameController,
                icon: LucideIcons.user,
                hint: 'Ad Soyad',
                maxLength: _maxFieldLength,
                textCapitalization: TextCapitalization.words,
                autofillHints: const [AutofillHints.name],
              ),
              const SizedBox(height: 16),

              // E-posta
              _buildTextField(
                controller: _emailController,
                icon: LucideIcons.mail,
                hint: 'E-posta Adresi',
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
              ),
              const SizedBox(height: 16),

              // Şehir
              _buildTextField(
                controller: _cityController,
                icon: LucideIcons.mapPin,
                hint: 'İstanbul',
                maxLength: _maxFieldLength,
                textCapitalization: TextCapitalization.words,
                autofillHints: const [AutofillHints.addressCity],
                onChanged: (_) => setState(() {}), // Rebuild for district enable/disable
              ),
              const SizedBox(height: 16),

              // İlçe (disabled if city empty)
              _buildTextField(
                controller: _districtController,
                icon: LucideIcons.mapPin,
                hint: 'Kadıköy',
                maxLength: _maxFieldLength,
                textCapitalization: TextCapitalization.words,
                enabled: isCityFilled,
              ),
              const SizedBox(height: 16),

              // Şifre
              _buildTextField(
                controller: _passwordController,
                icon: LucideIcons.lock,
                hint: 'Şifre',
                isPassword: true,
                obscureValue: _obscurePassword,
                onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                autofillHints: const [AutofillHints.newPassword],
              ),
              const SizedBox(height: 16),

              // Şifre Tekrar
              _buildTextField(
                controller: _confirmPasswordController,
                icon: LucideIcons.lock,
                hint: 'Şifre Tekrar',
                isPassword: true,
                obscureValue: _obscureConfirm,
                onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                autofillHints: const [AutofillHints.newPassword],
              ),

              const SizedBox(height: 28),

              // KVKK Checkbox
              _buildLegalCheckbox(
                label: 'KVKK Aydınlatma Metni',
                value: _kvkkAccepted,
                enabled: _kvkkOpened,
                onChanged: _kvkkOpened
                    ? (val) => setState(() => _kvkkAccepted = val ?? false)
                    : null,
                onTapText: _showKvkkSheet,
              ),
              const SizedBox(height: 10),

              // Açık Rıza Checkbox
              _buildLegalCheckbox(
                label: 'Açık Rıza Metni',
                value: _consentAccepted,
                enabled: _consentOpened,
                onChanged: _consentOpened
                    ? (val) => setState(() => _consentAccepted = val ?? false)
                    : null,
                onTapText: _showConsentSheet,
              ),

              const SizedBox(height: 32),

              // Kayıt Ol butonu
              _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.ciniMavisi))
                  : ElevatedButton(
                      onPressed: _handleRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.ciniMavisi,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: const Text('Kayıt Ol',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegalCheckbox({
    required String label,
    required bool value,
    required bool enabled,
    required ValueChanged<bool?>? onChanged,
    required VoidCallback onTapText,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            side: BorderSide(
              color: enabled ? AppColors.textMuted : AppColors.surfaceBorder,
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: onTapText,
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$label\'ni okudum, kabul ediyorum.',
                    style: TextStyle(
                      color: enabled ? AppColors.textSecondary : AppColors.textMuted,
                      fontSize: 13,
                      height: 1.3,
                    ),
                  ),
                  if (!enabled)
                    const TextSpan(
                      text: ' (Önce okuyun)',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    bool isPassword = false,
    bool obscureValue = false,
    bool enabled = true,
    VoidCallback? onToggle,
    int? maxLength,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<String>? autofillHints,
    ValueChanged<String>? onChanged,
  }) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: TextField(
          controller: controller,
          obscureText: isPassword ? obscureValue : false,
          enabled: enabled,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          autofillHints: autofillHints,
          maxLength: maxLength,
          onChanged: onChanged,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.textMuted, size: 20),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      obscureValue ? LucideIcons.eyeOff : LucideIcons.eye,
                      color: AppColors.textMuted,
                      size: 18,
                    ),
                    onPressed: onToggle,
                  )
                : null,
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
            border: InputBorder.none,
            counterText: '', // Hide counter
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // KVKK & Consent Dummy Texts
  // =========================================================================
  static const String _kvkkDummyText = '''
KİŞİSEL VERİLERİN KORUNMASI KANUNU (KVKK) AYDINLATMA METNİ

Son Güncelleme: 01.01.2026

1. VERİ SORUMLUSU
Gezdirelim Teknoloji A.Ş. ("Şirket") olarak, 6698 sayılı Kişisel Verilerin Korunması Kanunu ("KVKK") kapsamında kişisel verilerinizin korunmasına büyük önem vermekteyiz. Bu aydınlatma metni, kişisel verilerinizin işlenme amaçları, hukuki sebepleri, toplanma yöntemleri ve haklarınız hakkında sizi bilgilendirmek amacıyla hazırlanmıştır.

2. İŞLENEN KİŞİSEL VERİLER
Uygulamamız aracılığıyla aşağıdaki kişisel verileriniz işlenmektedir:

- Kimlik Bilgileri: Ad, soyad, doğum tarihi
- İletişim Bilgileri: E-posta adresi, telefon numarası
- Lokasyon Bilgileri: Şehir, ilçe, konum verileri
- Kullanım Verileri: Uygulama kullanım istatistikleri, rota bilgileri, tercihler
- Görsel Veriler: Profil fotoğrafı

3. KİŞİSEL VERİLERİN İŞLENME AMAÇLARI
Kişisel verileriniz aşağıdaki amaçlarla işlenmektedir:

a) Üyelik işlemlerinin gerçekleştirilmesi
b) Hizmetlerimizin sunulması ve iyileştirilmesi
c) Rota oluşturma ve paylaşma hizmetlerinin sağlanması
d) Kullanıcı deneyiminin kişiselleştirilmesi
e) İstatistiksel analizlerin yapılması
f) Yasal yükümlülüklerin yerine getirilmesi
g) Güvenlik önlemlerinin alınması

4. KİŞİSEL VERİLERİN AKTARIMI
Kişisel verileriniz, yukarıda belirtilen amaçlar doğrultusunda, iş ortaklarımıza, tedarikçilerimize, hizmet aldığımız üçüncü kişilere, yasal zorunluluk halinde yetkili kamu kurum ve kuruluşlarına aktarılabilecektir.

5. KİŞİSEL VERİLERİN TOPLANMA YÖNTEMİ VE HUKUKİ SEBEBİ
Kişisel verileriniz, elektronik ortamda uygulama üzerinden, açık rızanız ve/veya kanuni yükümlülüklerimiz kapsamında toplanmaktadır.

6. HAKLARINIZ
KVKK'nın 11. maddesi kapsamında aşağıdaki haklara sahipsiniz:

a) Kişisel verilerinizin işlenip işlenmediğini öğrenme
b) İşlenmişse buna ilişkin bilgi talep etme
c) İşlenme amacını ve bunların amacına uygun kullanılıp kullanılmadığını öğrenme
d) Yurt içinde veya yurt dışında kişisel verilerin aktarıldığı üçüncü kişileri bilme
e) Kişisel verilerin eksik veya yanlış işlenmiş olması hâlinde bunların düzeltilmesini isteme
f) KVKK'nın 7. maddesinde öngörülen şartlar çerçevesinde silinmesini veya yok edilmesini isteme
g) Aktarılan üçüncü kişilere bildirilmesini isteme
h) İşlenen verilerin münhasıran otomatik sistemler vasıtasıyla analiz edilmesi suretiyle aleyhine bir sonucun ortaya çıkmasına itiraz etme
i) Kanuna aykırı olarak işlenmesi sebebiyle zarara uğraması hâlinde zararın giderilmesini talep etme

Haklarınızı kullanmak için destek@gezdirelim.com adresine başvurabilirsiniz.
''';

  static const String _consentDummyText = '''
AÇIK RIZA METNİ

Son Güncelleme: 01.01.2026

Gezdirelim Teknoloji A.Ş. ("Şirket") tarafından, 6698 sayılı Kişisel Verilerin Korunması Kanunu ("KVKK") kapsamında hazırlanan işbu Açık Rıza Metni ile kişisel verilerimin işlenmesine ilişkin aşağıdaki hususlarda bilgilendirildim.

1. AÇIK RIZANIN KONUSU
İşbu açık rıza metni ile aşağıda belirtilen kişisel verilerimin, belirtilen amaçlar doğrultusunda işlenmesine onay veriyorum:

- Konum verilerimin rota oluşturma ve kişiselleştirilmiş öneriler sunulması amacıyla işlenmesi
- Kullanım alışkanlıklarımın analiz edilerek hizmet kalitesinin artırılması
- Profil bilgilerimin diğer kullanıcılar tarafından görüntülenebilmesi
- E-posta adresime bilgilendirme ve kampanya mesajları gönderilmesi

2. VERİLERİN İŞLENME SÜRESİ
Kişisel verileriniz, işlenme amaçlarının gerektirdiği süre boyunca ve yasal düzenlemelerin öngördüğü zorunlu saklama süreleri boyunca muhafaza edilecektir. Bu sürelerin sona ermesi halinde kişisel verileriniz silinecek, yok edilecek veya anonim hâle getirilecektir.

3. AÇIK RIZANIN GERİ ALINMASI
Açık rızanızı her zaman, herhangi bir gerekçe belirtmeksizin geri alma hakkına sahipsiniz. Açık rızanızı geri almak için destek@gezdirelim.com adresine başvurabilirsiniz.

Açık rızanın geri alınması, geri alınmadan önce yapılan veri işleme faaliyetlerinin hukuka uygunluğunu etkilemeyecektir.

4. ONAY
Yukarıda belirtilen hususlarda tarafıma gerekli aydınlatmanın yapıldığını, metni okuduğumu, anladığımı ve kişisel verilerimin yukarıda belirtilen amaçlar doğrultusunda işlenmesine özgür iradem ile açık rıza verdiğimi kabul ve beyan ederim.
''';
}
