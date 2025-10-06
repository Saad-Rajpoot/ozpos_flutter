import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';

/// Database helper for SQLite operations
class DatabaseHelper {
  static Database? _database;
  static const String _databaseName = 'ozpos.db';
  static const int _databaseVersion = 1;

  /// Get database instance
  static Future<Database> get database async {
    if (_database != null) return _database!;
    
    // For web, use a mock database or skip database operations
    if (kIsWeb) {
      throw UnsupportedError('Database operations not supported on web');
    }
    
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize database
  static Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Create database tables
  static Future<void> _onCreate(Database db, int version) async {
    // Menu items table
    await db.execute('''
      CREATE TABLE menu_items (
        id TEXT PRIMARY KEY,
        category_id TEXT NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        image TEXT,
        base_price REAL NOT NULL,
        tags TEXT,
        requires_customization INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Menu categories table
    await db.execute('''
      CREATE TABLE menu_categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        image TEXT,
        sort_order INTEGER NOT NULL DEFAULT 0,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Modifier groups table
    await db.execute('''
      CREATE TABLE modifier_groups (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        is_required INTEGER NOT NULL DEFAULT 0,
        min_selections INTEGER NOT NULL DEFAULT 0,
        max_selections INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Modifiers table
    await db.execute('''
      CREATE TABLE modifiers (
        id TEXT PRIMARY KEY,
        group_id TEXT NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        price_delta REAL NOT NULL DEFAULT 0,
        is_available INTEGER NOT NULL DEFAULT 1,
        sort_order INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (group_id) REFERENCES modifier_groups (id)
      )
    ''');

    // Orders table
    await db.execute('''
      CREATE TABLE orders (
        id TEXT PRIMARY KEY,
        order_number TEXT NOT NULL UNIQUE,
        order_type TEXT NOT NULL,
        status TEXT NOT NULL,
        table_number TEXT,
        customer_name TEXT,
        customer_phone TEXT,
        customer_address TEXT,
        subtotal REAL NOT NULL,
        tax_amount REAL NOT NULL,
        tip_amount REAL NOT NULL DEFAULT 0,
        total_amount REAL NOT NULL,
        payment_method TEXT,
        payment_status TEXT NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Order items table
    await db.execute('''
      CREATE TABLE order_items (
        id TEXT PRIMARY KEY,
        order_id TEXT NOT NULL,
        menu_item_id TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        unit_price REAL NOT NULL,
        total_price REAL NOT NULL,
        special_instructions TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (order_id) REFERENCES orders (id),
        FOREIGN KEY (menu_item_id) REFERENCES menu_items (id)
      )
    ''');

    // Order item modifiers table
    await db.execute('''
      CREATE TABLE order_item_modifiers (
        id TEXT PRIMARY KEY,
        order_item_id TEXT NOT NULL,
        modifier_id TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (order_item_id) REFERENCES order_items (id),
        FOREIGN KEY (modifier_id) REFERENCES modifiers (id)
      )
    ''');

    // Tables table
    await db.execute('''
      CREATE TABLE tables (
        id TEXT PRIMARY KEY,
        table_number TEXT NOT NULL UNIQUE,
        capacity INTEGER NOT NULL,
        status TEXT NOT NULL DEFAULT 'available',
        area TEXT,
        position_x REAL,
        position_y REAL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Reservations table
    await db.execute('''
      CREATE TABLE reservations (
        id TEXT PRIMARY KEY,
        customer_name TEXT NOT NULL,
        customer_phone TEXT NOT NULL,
        party_size INTEGER NOT NULL,
        reservation_date TEXT NOT NULL,
        reservation_time TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'pending',
        table_id TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (table_id) REFERENCES tables (id)
      )
    ''');

    // Cart items table
    await db.execute('''
      CREATE TABLE cart_items (
        line_item_id TEXT PRIMARY KEY,
        item_id TEXT NOT NULL,
        item_name TEXT NOT NULL,
        item_image TEXT,
        unit_price REAL NOT NULL,
        quantity INTEGER NOT NULL,
        total_price REAL NOT NULL,
        special_instructions TEXT,
        modifiers TEXT,
        added_at TEXT NOT NULL
      )
    ''');

    // Sync queue table
    await db.execute('''
      CREATE TABLE sync_queue (
        id TEXT PRIMARY KEY,
        table_name TEXT NOT NULL,
        record_id TEXT NOT NULL,
        operation TEXT NOT NULL,
        data TEXT NOT NULL,
        created_at TEXT NOT NULL,
        synced_at TEXT,
        retry_count INTEGER NOT NULL DEFAULT 0,
        error_message TEXT
      )
    ''');

    // Create indexes
    await db.execute('CREATE INDEX idx_menu_items_category ON menu_items(category_id)');
    await db.execute('CREATE INDEX idx_order_items_order ON order_items(order_id)');
    await db.execute('CREATE INDEX idx_sync_queue_table ON sync_queue(table_name)');
    await db.execute('CREATE INDEX idx_sync_queue_synced ON sync_queue(synced_at)');
  }

  /// Upgrade database
  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
    // For now, we'll just recreate the database
    if (oldVersion < newVersion) {
      await _onCreate(db, newVersion);
    }
  }

  /// Close database
  static Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
