// lib/data/local/database_helper.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../core/constants/app_constants.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.dbName);

    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createTables(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Migration support — drop and recreate for v1
    if (oldVersion < newVersion) {
      await _dropTables(db);
      await _createTables(db);
    }
  }

  Future<void> _createTables(Database db) async {
    // Transactions table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS transactions (
        id TEXT PRIMARY KEY,
        merchantName TEXT NOT NULL,
        category TEXT NOT NULL,
        notes TEXT DEFAULT '',
        sourceRef TEXT DEFAULT '',
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        source TEXT NOT NULL DEFAULT 'manual',
        date TEXT NOT NULL,
        isReviewed INTEGER NOT NULL DEFAULT 1,
        isDuplicate INTEGER NOT NULL DEFAULT 0,
        confidenceScore REAL NOT NULL DEFAULT 1.0,
        linkedCommitmentId TEXT,
        accountLast4 TEXT
      )
    ''');

    // Commitments table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS commitments (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        lender TEXT NOT NULL,
        amount REAL NOT NULL,
        monthlyReserve REAL NOT NULL,
        type TEXT NOT NULL,
        dueDate TEXT NOT NULL,
        startDate TEXT NOT NULL,
        remainingInstallments INTEGER,
        isPaid INTEGER NOT NULL DEFAULT 0,
        policyReference TEXT,
        vehicleNumber TEXT,
        annualPremium REAL,
        savingMonths INTEGER,
        loanAccountNumber TEXT,
        notes TEXT DEFAULT ''
      )
    ''');

    // Goals table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS goals (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        targetAmount REAL NOT NULL,
        currentAmount REAL NOT NULL DEFAULT 0,
        monthlyContribution REAL NOT NULL,
        targetDate TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        notes TEXT DEFAULT '',
        isCompleted INTEGER NOT NULL DEFAULT 0,
        isActive INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // Income sources table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS income_sources (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        paydayOfMonth INTEGER NOT NULL,
        isRegular INTEGER NOT NULL DEFAULT 1,
        status TEXT NOT NULL DEFAULT 'expected',
        employerName TEXT,
        accountLast4 TEXT,
        createdAt TEXT NOT NULL,
        isActive INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // User profile table (single row)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS user_profile (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        paydayOfMonth INTEGER NOT NULL,
        payCycle TEXT NOT NULL DEFAULT '1st',
        appLockEnabled INTEGER NOT NULL DEFAULT 0,
        appLockType TEXT NOT NULL DEFAULT 'none',
        themeMode TEXT NOT NULL DEFAULT 'system',
        notificationsEnabled INTEGER NOT NULL DEFAULT 1,
        reminderDaysBefore INTEGER NOT NULL DEFAULT 3,
        createdAt TEXT NOT NULL,
        lastBackupAt TEXT
      )
    ''');

    // Budget cycles table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS budget_cycles (
        id TEXT PRIMARY KEY,
        startDate TEXT NOT NULL,
        endDate TEXT NOT NULL,
        confirmedIncome REAL NOT NULL,
        commitmentReserve REAL NOT NULL,
        plannedSavings REAL NOT NULL,
        otherReserves REAL NOT NULL DEFAULT 0,
        flexibleBudget REAL NOT NULL,
        paydayOfMonth INTEGER NOT NULL
      )
    ''');

    // Category rules table (learned patterns)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS category_rules (
        id TEXT PRIMARY KEY,
        merchantPattern TEXT NOT NULL,
        category TEXT NOT NULL,
        transactionType TEXT NOT NULL,
        confidence REAL NOT NULL DEFAULT 1.0,
        usageCount INTEGER NOT NULL DEFAULT 1,
        lastUsed TEXT NOT NULL
      )
    ''');

    // Category budgets table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS category_budgets (
        id TEXT PRIMARY KEY,
        budgetCycleId TEXT NOT NULL,
        category TEXT NOT NULL,
        budgeted REAL NOT NULL,
        spent REAL NOT NULL DEFAULT 0,
        FOREIGN KEY (budgetCycleId) REFERENCES budget_cycles(id)
      )
    ''');
  }

  Future<void> _dropTables(Database db) async {
    final tables = [
      'transactions', 'commitments', 'goals', 'income_sources',
      'user_profile', 'budget_cycles', 'category_rules', 'category_budgets'
    ];
    for (final table in tables) {
      await db.execute('DROP TABLE IF EXISTS $table');
    }
  }

  // ==================== Generic CRUD ====================

  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return db.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> update(
    String table,
    Map<String, dynamic> data,
    String where,
    List<dynamic> whereArgs,
  ) async {
    final db = await database;
    return db.update(table, data, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(String table, String where, List<dynamic> whereArgs) async {
    final db = await database;
    return db.delete(table, where: where, whereArgs: whereArgs);
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final db = await database;
    return db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<dynamic>? args,
  ]) async {
    final db = await database;
    return db.rawQuery(sql, args);
  }

  Future<int> count(String table, {String? where, List<dynamic>? whereArgs}) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $table${where != null ? ' WHERE $where' : ''}',
      whereArgs,
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> clearAll() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('transactions');
      await txn.delete('commitments');
      await txn.delete('goals');
      await txn.delete('income_sources');
      await txn.delete('budget_cycles');
      await txn.delete('category_rules');
      await txn.delete('category_budgets');
    });
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
