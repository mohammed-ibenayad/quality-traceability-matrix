#!/usr/bin/env node
/**
 * Database Initialization Script
 * Runs schema creation and seeds initial data
 */

const fs = require('fs');
const path = require('path');
const { query } = require('../connection');

async function runInit() {
  try {
    console.log('🚀 Starting database initialization...\n');

    // Step 1: Run schema creation
    console.log('📄 Step 1: Creating database schema...');
    const schemaPath = path.join(__dirname, '01-schema.sql');
    const schemaSql = fs.readFileSync(schemaPath, 'utf8');

    await query(schemaSql);
    console.log('✅ Schema created successfully!\n');

    // Step 2: Seed initial data
    console.log('🌱 Step 2: Seeding initial data...');

    const DEFAULT_WORKSPACE_ID = '00000000-0000-0000-0000-000000000002';
    const DEFAULT_USER_ID = '00000000-0000-0000-0000-000000000001';

    // Create default user with password "admin123"
    await query(`
      INSERT INTO users (id, email, full_name, password_hash, is_active, email_verified)
      VALUES ($1, $2, $3, crypt($4, gen_salt('bf')), $5, $6)
      ON CONFLICT (id) DO NOTHING
    `, [DEFAULT_USER_ID, 'admin@qualitytracker.local', 'Admin User', 'admin123', true, true]);

    // Create default workspace
    await query(`
      INSERT INTO workspaces (id, name, slug, description, owner_id, is_active)
      VALUES ($1, $2, $3, $4, $5, $6)
      ON CONFLICT (id) DO NOTHING
    `, [DEFAULT_WORKSPACE_ID, 'Default Workspace', 'default-workspace',
        'Default workspace for single-user mode', DEFAULT_USER_ID, true]);

    // Add user to workspace
    await query(`
      INSERT INTO workspace_members (workspace_id, user_id, role, joined_at)
      VALUES ($1, $2, $3, NOW())
      ON CONFLICT (workspace_id, user_id) DO NOTHING
    `, [DEFAULT_WORKSPACE_ID, DEFAULT_USER_ID, 'owner']);

    console.log('✅ Initial data seeded successfully!\n');

    // Summary
    console.log('═══════════════════════════════════════════════════════════');
    console.log('✅ Database initialization completed successfully!');
    console.log('═══════════════════════════════════════════════════════════');
    console.log('');
    console.log('📧 Default user credentials:');
    console.log('   Email:    admin@qualitytracker.local');
    console.log('   Password: admin123');
    console.log('');
    console.log('🏢 Default workspace:');
    console.log('   Name: Default Workspace');
    console.log('   ID:   ' + DEFAULT_WORKSPACE_ID);
    console.log('');
    console.log('🔐 IMPORTANT: Change the default password after first login!');
    console.log('');

    process.exit(0);
  } catch (error) {
    console.error('❌ Database initialization failed:', error.message);
    console.error('');
    console.error('Details:', error);
    console.error('');
    console.error('💡 Troubleshooting:');
    console.error('   1. Make sure PostgreSQL is running: sudo systemctl status postgresql');
    console.error('   2. Check database connection settings in packages/backend/.env');
    console.error('   3. Verify database user has proper permissions');
    console.error('');
    process.exit(1);
  }
}

// Run if called directly
if (require.main === module) {
  runInit();
}

module.exports = { runInit };
