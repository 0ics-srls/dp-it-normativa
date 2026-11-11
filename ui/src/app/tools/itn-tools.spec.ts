import { TestBed } from '@angular/core/testing';
import { actWire } from '../testing/itn-fixtures';
import { callsOf, stubItnEnvironment } from '../testing/stub-itn-tools';
import { ItnToolError, ItnTools } from './itn-tools';

function facade(handlers: Parameters<typeof stubItnEnvironment>[0]) {
  const env = stubItnEnvironment(handlers);
  TestBed.configureTestingModule({ providers: [...env.providers, ItnTools] });
  return { env, tools: TestBed.inject(ItnTools) };
}

describe('ItnTools', () => {
  it('should map snake case rows to camel case with a Date version when acts are found', async () => {
    const { tools } = facade({ acts_find: () => [actWire()] });
    const [row] = await tools.findActs({ q: 'x', limit: 50, offset: 0 });
    expect(row).toEqual({
      act: 'LEGGE 27 luglio 2000, n. 212',
      urn: 'urn:nir:stato:legge:2000-07-27;212',
      unitCount: 40,
      version: new Date('2024-01-15'),
      total: 3,
    });
  });

  it('should send only declared snake case keys and drop empty ones when a Tool is called', async () => {
    const { env, tools } = facade({ acts_find: () => [] });
    await tools.findActs({ q: '', collection: undefined, limit: 50, offset: 0 });
    expect(callsOf(env, 'acts_find')).toEqual([{ q: '', limit: 50, offset: 0 }]);
  });

  it('should accept a data envelope when the Host wraps the rows', async () => {
    const { tools } = facade({ acts_find: () => ({ data: [actWire()] }) });
    expect(await tools.findActs({ limit: 50, offset: 0 })).toHaveLength(1);
  });

  it('should throw an ItnToolError naming the Tool when the call rejects', async () => {
    const { tools } = facade({
      acts_find: () => {
        throw Object.assign(new Error('nope'), { code: 'timeout' });
      },
    });
    await expect(tools.findActs({ limit: 50, offset: 0 })).rejects.toMatchObject({ tool: 'acts_find', code: 'timeout' });
    await expect(tools.findActs({ limit: 50, offset: 0 })).rejects.toBeInstanceOf(ItnToolError);
  });
});
