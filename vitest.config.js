import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    globals: true,
    fileParallelism: false,
    env: {
      JWT_SECRET: 'spark-vitest-secret-not-for-production',
    },
  },
});
