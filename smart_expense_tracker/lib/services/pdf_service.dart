import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../models/debt_record.dart';
import '../models/person.dart';
import '../providers/debt_provider.dart';

class PdfService {
  static final _dateFormat = DateFormat('dd/MM/yyyy');
  static final _currencyFormat = NumberFormat('#,##0.00');

  // Colors
  static const PdfColor _primaryColor = PdfColor.fromInt(0xFF1E2E4F);
  static const PdfColor _accentColor = PdfColor.fromInt(0xFF69B39C);
  static const PdfColor _textColor = PdfColor.fromInt(0xFF333333);
  static const PdfColor _lightGray = PdfColor.fromInt(0xFFF5F5F5);

  // --- Styles ---
  static pw.TextStyle get _headerStyle => pw.TextStyle(
        fontSize: 24,
        fontWeight: pw.FontWeight.bold,
        color: _primaryColor,
      );

  static pw.TextStyle get _subHeaderStyle => pw.TextStyle(
        fontSize: 18,
        fontWeight: pw.FontWeight.bold,
        color: _textColor,
      );

  static pw.TextStyle get _normalStyle => const pw.TextStyle(
        fontSize: 12,
        color: _textColor,
      );

  static pw.TextStyle get _boldStyle => pw.TextStyle(
        fontSize: 12,
        fontWeight: pw.FontWeight.bold,
        color: _textColor,
      );

  // --- Generic Header Construction ---
  static pw.Widget _buildHeader(String title, String userName) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(title, style: _headerStyle),
            pw.Text('Smart Expense Tracker',
                style: pw.TextStyle(
                    color: _accentColor, fontWeight: pw.FontWeight.bold)),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Generated for: $userName', style: _normalStyle),
            pw.Text('Date: ${_dateFormat.format(DateTime.now())}',
                style: _normalStyle),
          ],
        ),
        pw.Divider(color: _accentColor, thickness: 2),
        pw.SizedBox(height: 20),
      ],
    );
  }

  // --- 1. Expenses Report ---
  static Future<void> generateExpensesReport(List<Expense> expenses,
      String currencySymbol, String userName) async {
    final doc = pw.Document();
    final totalSpent = expenses.fold(0.0, (sum, e) => sum + e.amount);

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          _buildHeader('Expenses Report', userName),
          // Summary
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: _lightGray,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Total Expenses:', style: _subHeaderStyle),
                pw.Text(
                  '$currencySymbol${_currencyFormat.format(totalSpent)}',
                  style: _subHeaderStyle.copyWith(color: PdfColors.red900),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          // Table
          pw.Table.fromTextArray(
            headers: ['Date', 'Category', 'Note', 'Amount'],
            data: expenses.map((e) {
              return [
                _dateFormat.format(e.date),
                e.category,
                e.note,
                '$currencySymbol${_currencyFormat.format(e.amount)}',
              ];
            }).toList(),
            headerStyle: _boldStyle.copyWith(color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(color: _primaryColor),
            cellStyle: _normalStyle,
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.centerLeft,
              2: pw.Alignment.centerLeft,
              3: pw.Alignment.centerRight,
            },
            border: null,
            rowDecoration: const pw.BoxDecoration(
              border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5)),
            ),
            cellPadding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          ),
        ],
      ),
    );

    await Printing.sharePdf(
        bytes: await doc.save(), filename: 'expenses_report.pdf');
  }

  // --- 2. Debts Global Report (People Summary) ---
  static Future<void> generateDebtsSummaryReport(List<Person> people,
      DebtProvider provider, String currencySymbol, String userName) async {
    final doc = pw.Document();

    double grandTotalDebt = provider.totalDebt;
    double grandTotalPayback = provider.totalPayback;

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          _buildHeader('Debts & Paybacks Summary', userName),
          // Global Summary
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.red50,
                  borderRadius: pw.BorderRadius.circular(8),
                  border: pw.Border.all(color: PdfColors.red200),
                ),
                child: pw.Column(
                  children: [
                    pw.Text('Total Debt (Receivable)', style: _boldStyle),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      '$currencySymbol${_currencyFormat.format(grandTotalDebt)}',
                      style: _subHeaderStyle.copyWith(color: PdfColors.red900),
                    ),
                  ],
                ),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.green50,
                  borderRadius: pw.BorderRadius.circular(8),
                  border: pw.Border.all(color: PdfColors.green200),
                ),
                child: pw.Column(
                  children: [
                    pw.Text('Total Payback (Payable)', style: _boldStyle),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      '$currencySymbol${_currencyFormat.format(grandTotalPayback)}',
                      style: _subHeaderStyle.copyWith(color: PdfColors.green900),
                    ),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 25),
          pw.Text('People Details', style: _subHeaderStyle),
          pw.SizedBox(height: 10),
          // Table
          pw.Table.fromTextArray(
            headers: ['Name', 'Phone', 'Net Balance', 'Status'],
            data: people.map((p) {
              final balance =
                  provider.getPersonBalance(p.key.toString());
              final isReceivable = balance > 0;
              final status = isReceivable ? 'Owes You' : 'You Owe';
              // If balance is 0, status is Settled
              final statusStr = balance == 0 ? 'Settled' : status;

              return [
                p.name,
                p.phoneNumber,
                '$currencySymbol${_currencyFormat.format(balance.abs())}',
                statusStr,
              ];
            }).toList(),
             headerStyle: _boldStyle.copyWith(color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(color: _primaryColor),
            cellStyle: _normalStyle,
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.centerLeft,
              2: pw.Alignment.centerRight,
              3: pw.Alignment.center,
            },
           border: null,
            rowDecoration: const pw.BoxDecoration(
              border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5)),
            ),
             cellPadding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          ),
        ],
      ),
    );

    await Printing.sharePdf(
        bytes: await doc.save(), filename: 'debts_summary_report.pdf');
  }

  // --- 3. Person Detail Report ---
  static Future<void> generatePersonReport(Person person,
      List<DebtRecord> records, String currencySymbol) async {
    final doc = pw.Document();

    // Calculate totals for this person
    double totalDebt = 0;
    double totalPaid = 0; // Or Total Payback depending on definitions, usually Payback type
    // Wait, the debt_record has 'type' which is 'debt' or 'payback'
    // 'debt' means they took money (positive balance usually)
    // 'payback' means I took money or they paid back?
    // Let's stick to the logic in provider:
    // debt -> +amount (Owes You)
    // payback -> -amount (You Owe)
    
    // Also records have 'isPaid' flag if it was a specific debt record marked as paid.
    // The report should list all transactions.

    double netBalance = 0;
    for (var r in records) {
        if (r.type == 'debt') netBalance += r.amount;
        else netBalance -= r.amount;
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          _buildHeader('Person Statement', person.name), 
           // Person Info Card
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              borderRadius: pw.BorderRadius.circular(8),
              border: pw.Border.all(color: _accentColor),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Person: ${person.name}', style: _boldStyle),
                    pw.Text('Phone: ${person.phoneNumber}', style: _normalStyle),
                  ],
                ),
                 pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('Net Balance:', style: _boldStyle),
                    pw.Text(
                      '$currencySymbol${_currencyFormat.format(netBalance.abs())}',
                      style: _headerStyle.copyWith(
                          fontSize: 20,
                          color: netBalance > 0 ? PdfColors.red900 : (netBalance < 0 ? PdfColors.green900 : PdfColors.black)),
                    ),
                    pw.Text(netBalance > 0 ? 'Owes You' : (netBalance < 0 ? 'You Owe' : 'Settled'), style: _normalStyle),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          
          pw.Text('Transaction History', style: _subHeaderStyle),
           pw.SizedBox(height: 10),

          // Table
          pw.Table.fromTextArray(
            headers: ['Date', 'Type', 'Note', 'Amount', 'Status'],
            data: records.map((r) {
              final isDebt = r.type == 'debt';
              final typeStr = isDebt ? 'Debt (Lent)' : 'Payback (Borrowed)';
              final status = r.isPaid ? 'PAID' : (isDebt ? 'Unpaid' : '-');
              
              PdfColor amountColor = isDebt ? PdfColors.red900 : PdfColors.green900;
              if (r.isPaid) amountColor = PdfColors.grey;

              return [
                _dateFormat.format(r.date),
                typeStr,
                r.note,
                '$currencySymbol${_currencyFormat.format(r.amount)}',
                status,
              ];
            }).toList(),
            headerStyle: _boldStyle.copyWith(color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(color: _primaryColor),
            cellStyle: _normalStyle,
             cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.centerLeft,
              2: pw.Alignment.centerLeft,
              3: pw.Alignment.centerRight,
              4: pw.Alignment.center,
            },
           border: null,
            rowDecoration: const pw.BoxDecoration(
              border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5)),
            ),
             cellPadding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          ),
        ],
      ),
    );

    await Printing.sharePdf(
        bytes: await doc.save(), filename: '${person.name}_statement.pdf');
  }
}
