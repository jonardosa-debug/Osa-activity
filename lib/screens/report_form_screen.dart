import 'package:flutter/material.dart';

import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';

/// Activity 9 - The four essential asynchronous UI responses of the
/// Report Form screen, plus the initial idle state.
enum ReportUiState { idle, loading, success, empty, error }

/// Simple in-memory record of a submitted report.
///
/// NOTE: Activity 9 uses SIMULATED asynchronous responses (Future.delayed).
/// No real database record is created. When the REST API + PostgreSQL
/// backend is connected later, submissions will be stored on the server.
class SubmittedReport {
  const SubmittedReport({
    required this.referenceNumber,
    required this.title,
    required this.country,
    required this.category,
    required this.dateSubmitted,
  });

  final String referenceNumber;
  final String title;
  final String country;
  final String category;
  final String dateSubmitted;
}

/// SmartTrack Report Form (Activity 9).
///
/// Reachable from the Home dashboard via the '/report' route. Reuses the
/// shared [AppTextField] and [AppButton] widgets from lib/widgets/.
class ReportFormScreen extends StatefulWidget {
  const ReportFormScreen({super.key});

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  static const Color _sidebar = Color(0xFF1A237E);

  static const List<String> _categories = <String>[
    'Travel Monitoring',
    'Document Compliance',
    'Announcement / Notice',
    'Incident Report',
    'Other',
  ];

  static const List<String> _months = <String>[
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  // --- Form state -----------------------------------------------------------
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final List<SubmittedReport> _submittedReports = <SubmittedReport>[];

  String _category = _categories.first;
  bool _simulateFailure = false; // Demo toggle for the Error state.
  ReportUiState _uiState = ReportUiState.idle;
  String? _errorMessage;

  @override
  void dispose() {
    _titleController.dispose();
    _countryController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool get _isSubmitting => _uiState == ReportUiState.loading;

  /// Simulated asynchronous submission (see class doc comment).
  Future<void> submitReport() async {
    // Guard 1: never allow duplicate submissions while a request is pending.
    if (_isSubmitting) return;

    // Guard 2: field-level validation (empty / invalid input is rejected).
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _uiState = ReportUiState.loading;
      _errorMessage = null;
    });

    try {
      // SIMULATED network delay until the real REST API is implemented.
      await Future<void>.delayed(const Duration(seconds: 3));

      // Deliberate simulated failure so the Error state can be demonstrated.
      if (_simulateFailure) {
        throw Exception('Simulated server failure (demo toggle is ON)');
      }

      if (!mounted) return;
      setState(() {
        _submittedReports.insert(
          0,
          SubmittedReport(
            referenceNumber:
                'RPT-${DateTime.now().millisecondsSinceEpoch % 1000000}',
            title: _titleController.text.trim(),
            country: _countryController.text.trim(),
            category: _category,
            dateSubmitted: _formatNow(),
          ),
        );
        _uiState = ReportUiState.success;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error
            .toString()
            .replaceFirst('Exception: ', '')
            .replaceFirst(' (demo toggle is ON)', '');
        _uiState = ReportUiState.error;
      });
    }
  }

  /// Clears the form and returns to the idle state for a new submission.
  void _resetForm() {
    _formKey.currentState?.reset();
    _titleController.clear();
    _countryController.clear();
    _descriptionController.clear();
    setState(() {
      _category = _categories.first;
      _simulateFailure = false;
      _errorMessage = null;
      _uiState = ReportUiState.idle;
    });
  }

  /// Removes all saved (simulated) records so the EMPTY state is
  /// reproducible at any time for demonstration and screenshots.
  void _clearReports() {
    setState(() {
      _submittedReports.clear();
      _errorMessage = null;
      _uiState = ReportUiState.idle;
    });
  }

  String _formatNow() {
    final DateTime now = DateTime.now();
    final String day = now.day.toString().padLeft(2, '0');
    return '${_months[now.month - 1]} $day, ${now.year}';
  }

  // --- Validation -----------------------------------------------------------

  String? _validateTitle(String? value) {
    final String text = value?.trim() ?? '';
    if (text.isEmpty) return 'Report title is required.';
    if (text.length < 5) return 'Title must be at least 5 characters.';
    return null;
  }

  String? _validateCountry(String? value) {
    final String text = value?.trim() ?? '';
    if (text.isEmpty) return 'Destination country is required.';
    if (text.length < 2) return 'Enter a valid country name.';
    return null;
  }

  String? _validateDescription(String? value) {
    final String text = value?.trim() ?? '';
    if (text.isEmpty) return 'A short description is required.';
    if (text.length < 10) return 'Description must be at least 10 characters.';
    return null;
  }

  // --- UI -------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5FB),
      appBar: AppBar(
        title: const Text('Report Form'),
        backgroundColor: Colors.white,
        foregroundColor: _sidebar,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) =>
              constraints.maxWidth >= 850
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(flex: 3, child: _buildFormCard(context)),
                        const SizedBox(width: 16),
                        Expanded(flex: 2, child: _buildFeedbackColumn(context)),
                      ],
                    )
                  : Column(
                      children: <Widget>[
                        // State panel on top so Loading/Success/Empty/Error
                        // responses are always immediately visible.
                        _buildFeedbackColumn(context),
                        const SizedBox(height: 16),
                        _buildFormCard(context),
                      ],
                    ),
        ),
      ),
    );
  }

  Widget _buildFeedbackColumn(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _buildStateResponse(context),
          const SizedBox(height: 16),
          _buildSubmittedReportsCard(context),
        ],
      );

  // --- Form card ------------------------------------------------------------

  Widget _buildFormCard(BuildContext context) => Card(
        elevation: 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'File a New Report',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Submit a report to the OIGE office. Fields marked with '
                  '* are required.',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 20),
                AppTextField(
                  label: 'Report Title *',
                  controller: _titleController,
                  prefixIcon: Icons.title,
                  hintText: 'e.g. Delayed Travel Document Submission',
                  validator: _validateTitle,
                  enabled: !_isSubmitting,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Destination Country *',
                  controller: _countryController,
                  prefixIcon: Icons.public,
                  hintText: 'e.g. Japan',
                  validator: _validateCountry,
                  enabled: !_isSubmitting,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  decoration: InputDecoration(
                    labelText: 'Report Category',
                    prefixIcon: const Icon(Icons.category_outlined),
                    filled: true,
                    fillColor: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withValues(alpha: 0.4),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: _categories
                      .map((String c) =>
                          DropdownMenuItem<String>(value: c, child: Text(c)))
                      .toList(),
                  onChanged: _isSubmitting
                      ? null
                      : (String? value) => setState(
                          () => _category = value ?? _categories.first),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Description *',
                  controller: _descriptionController,
                  prefixIcon: Icons.notes,
                  maxLines: 4,
                  hintText: 'Describe the report in at least 10 characters.',
                  validator: _validateDescription,
                  enabled: !_isSubmitting,
                ),
                const SizedBox(height: 8),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: _simulateFailure,
                  onChanged: _isSubmitting
                      ? null
                      : (bool value) =>
                          setState(() => _simulateFailure = value),
                  title: const Text(
                    'Simulate a failure (demo only)',
                    style: TextStyle(fontSize: 13),
                  ),
                  subtitle: const Text(
                    'Triggers the Error state so it can be demonstrated. '
                    'No real failure occurs.',
                    style: TextStyle(fontSize: 11, color: Colors.black54),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: AppButton(
                    label: _isSubmitting ? 'Submitting…' : 'Submit Report',
                    icon: Icons.send,
                    isLoading: _isSubmitting, // disables button, blocks duplicates
                    onPressed: submitReport,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  // --- Async state responses ------------------------------------------------

  Widget _buildStateResponse(BuildContext context) {
    switch (_uiState) {
      case ReportUiState.loading:
        return _stateCard(
          context,
          color: const Color(0xFFEF6C00),
          icon: Icons.hourglass_top,
          title: 'Submitting your report…',
          message:
              'Please wait while your request is being processed. '
              'Duplicate submissions are disabled. (Simulated 3-second delay)',
        );
      case ReportUiState.success:
        final SubmittedReport report = _submittedReports.first;
        return _stateCard(
          context,
          color: const Color(0xFF2E7D32),
          icon: Icons.check_circle_outline,
          title: 'Report submitted successfully',
          message:
              'Reference number: ${report.referenceNumber}\n'
              '"${report.title}" was recorded for ${report.country} on '
              '${report.dateSubmitted}. (Simulated response)',
          actionLabel: 'File Another Report',
          onAction: _resetForm,
        );
      case ReportUiState.error:
        return _stateCard(
          context,
          color: const Color(0xFFC62828),
          icon: Icons.error_outline,
          title: 'Submission failed',
          message:
              '${_errorMessage ?? 'Something went wrong.'}\n'
              'Your report was NOT submitted. Please check your connection '
              'or try again.',
          actionLabel: 'Retry',
          onAction: submitReport,
        );
      case ReportUiState.idle:
      case ReportUiState.empty:
        return const SizedBox.shrink();
    }
  }

  Widget _stateCard(
    BuildContext context, {
    required Color color,
    required IconData icon,
    required String title,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) =>
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                _uiState == ReportUiState.loading
                    ? SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: color,
                        ),
                      )
                    : Icon(icon, color: color, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(message, style: const TextStyle(fontSize: 13, height: 1.5)),
            if (actionLabel != null) ...<Widget>[
              const SizedBox(height: 12),
              AppButton(
                label: actionLabel,
                icon: _uiState == ReportUiState.error
                    ? Icons.refresh
                    : Icons.add,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      );

  // --- Submitted reports list (Idle / Empty states) -------------------------

  Widget _buildSubmittedReportsCard(BuildContext context) => Card(
        elevation: 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text(
                    'Submitted Reports',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  Row(
                    children: <Widget>[
                      Text(
                        '${_submittedReports.length} record(s)',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      if (_submittedReports.isNotEmpty) ...<Widget>[
                        const SizedBox(width: 8),
                        InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: _clearReports,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(Icons.delete_outline,
                                    size: 14, color: Color(0xFFC62828)),
                                SizedBox(width: 4),
                                Text(
                                  'Clear',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFFC62828),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_submittedReports.isEmpty)
                _buildEmptyState(context)
              else
                for (final SubmittedReport report in _submittedReports)
                  _buildReportItem(report),
            ],
          ),
        ),
      );

  /// EMPTY state: no report records available yet.
  Widget _buildEmptyState(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            children: <Widget>[
              Icon(Icons.inbox_outlined,
                  size: 48, color: _sidebar.withValues(alpha: 0.4)),
              const SizedBox(height: 12),
              const Text(
                'No reports available',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 6),
              const Text(
                'There are no submitted reports to display.\n'
                'Fill out the form and submit your first report.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 16),
              AppButton(
                label: 'Start a New Report',
                icon: Icons.add,
                onPressed: _resetForm,
              ),
            ],
          ),
        ),
      );

  Widget _buildReportItem(SubmittedReport report) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F5FB),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      report.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ),
                  Text(
                    report.referenceNumber,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${report.country} • ${report.category} • '
                '${report.dateSubmitted}',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
        ),
      );
}
