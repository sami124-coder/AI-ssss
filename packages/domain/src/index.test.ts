import { describe, expect, it } from 'vitest';
import { domainPackageName } from './index.js';

describe('domain package', () => {
  it('exposes its stable package identity', () => {
    expect(domainPackageName).toBe('@rda/domain');
  });
});
