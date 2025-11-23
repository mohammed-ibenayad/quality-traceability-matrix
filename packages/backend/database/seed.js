const { query, transaction } = require('./connection');

const DEFAULT_WORKSPACE_ID = '00000000-0000-0000-0000-000000000002';
const DEFAULT_USER_ID = '00000000-0000-0000-0000-000000000001';

async function seedDatabase() {
  try {
    console.log('🌱 Seeding database...');

    await transaction(async (client) => {
      // Create default user with password "admin123"
      await client.query(`
        INSERT INTO users (id, email, full_name, password_hash, is_active, email_verified)
        VALUES ($1, $2, $3, crypt($4, gen_salt('bf')), $5, $6)
        ON CONFLICT (id) DO NOTHING
      `, [DEFAULT_USER_ID, 'admin@qualitytracker.local', 'Admin User', 'admin123', true, true]);

      // Create default workspace
      await client.query(`
        INSERT INTO workspaces (id, name, slug, description, owner_id, is_active)
        VALUES ($1, $2, $3, $4, $5, $6)
        ON CONFLICT (id) DO NOTHING
      `, [DEFAULT_WORKSPACE_ID, 'Default Workspace', 'default-workspace',
          'Default workspace for single-user mode', DEFAULT_USER_ID, true]);

      // Add user to workspace
      await client.query(`
        INSERT INTO workspace_members (workspace_id, user_id, role, joined_at)
        VALUES ($1, $2, $3, NOW())
        ON CONFLICT (workspace_id, user_id) DO NOTHING
      `, [DEFAULT_WORKSPACE_ID, DEFAULT_USER_ID, 'owner']);
    });

    console.log('✅ Database seeded successfully!');
    console.log('📧 Default user: admin@qualitytracker.local');
    console.log('🔑 Default password: admin123');
    console.log('🏢 Default workspace: Default Workspace');
    console.log('🆔 Workspace ID:', DEFAULT_WORKSPACE_ID);

    process.exit(0);
  } catch (error) {
    console.error('❌ Seeding failed:', error.message);
    process.exit(1);
  }
}

seedDatabase();
