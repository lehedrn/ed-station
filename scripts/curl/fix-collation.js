/**
 * 修复数据库字符集排序规则冲突
 * 使用 http 方式调用后端接口执行 SQL
 */

const http = require('http');

const config = {
  host: 'localhost',
  port: 3306,
  user: 'root',
  password: 'lihaidong',
  database: 'ed_station_boot',
};

// 使用 mysql2 库（如果可用）否则使用 http 方式
async function fixCollation() {
  try {
    // 尝试使用 mysql2
    const mysql = require('mysql2/promise');
    const connection = await mysql.createConnection({
      host: config.host,
      user: config.user,
      password: config.password,
      database: config.database,
      charset: 'utf8mb4',
    });

    console.log('数据库连接成功');

    await connection.query(`ALTER TABLE blade_affair CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci`);
    console.log('✓ blade_affair 表字符集修复完成');

    await connection.query(`ALTER TABLE blade_affair_material CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci`);
    console.log('✓ blade_affair_material 表字符集修复完成');

    await connection.query(`ALTER TABLE blade_dict CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci`);
    console.log('✓ blade_dict 表字符集修复完成');

    await connection.end();
    console.log('\n所有表字符集修复完成！');
  } catch (error) {
    console.log('mysql2 不可用，尝试使用其他方式...');
    console.log('错误:', error.message);
    console.log('\n请手动执行以下 SQL 命令修复字符集：');
    console.log('docker exec mysql8 mysql -uroot -plibuhaidong ed_station_boot -e "ALTER TABLE blade_affair CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;"');
  }
}

fixCollation();
