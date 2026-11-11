import { Injectable } from '@angular/core';
import { injectPackageContext } from '@olx/package-ui-sdk';
import { ACT_DATES, AKN_DATES, STATUS_DATES, VERSION_DATES, type ActRow, type AknMeta, type CommaRow, type OutlineRow, type StatusRow, type VersionRow } from './itn-dto';
import { ItnTool, TOOL_INPUT_KEYS } from './itn-tool';

/** A Tool call failed; carries the Tool name and the code of the rejection when it had one. */
export class ItnToolError extends Error {
  constructor(
    readonly tool: ItnTool,
    readonly code: string | null,
    message: string,
  ) {
    super(message);
    this.name = 'ItnToolError';
  }
}

type Wire = Record<string, unknown>;

const camel = (key: string): string => key.replace(/_([a-z0-9])/g, (_, c: string) => c.toUpperCase());
const snake = (key: string): string => key.replace(/[A-Z]/g, (c) => `_${c.toLowerCase()}`);

function toDate(value: unknown): Date | null {
  if (value === null || value === undefined || value === '') {
    return null;
  }
  const date = new Date(typeof value === 'string' ? value : NaN);
  return Number.isNaN(date.getTime()) ? null : date;
}

function mapRow(row: Wire, dateKeys: readonly string[]): Wire {
  const mapped: Wire = {};
  for (const [key, value] of Object.entries(row)) {
    const name = camel(key);
    mapped[name] = dateKeys.includes(name) ? toDate(value) : value;
  }
  return mapped;
}

/** snake case input from camelCase arguments; undefined arguments are dropped, only keys of the Tool are sent. */
function buildInput(tool: ItnTool, args: Readonly<Record<string, unknown>>): Wire {
  const allowed = TOOL_INPUT_KEYS[tool];
  const input: Wire = {};
  for (const [key, value] of Object.entries(args)) {
    const wire = snake(key);
    if (value !== undefined && allowed.includes(wire)) {
      input[wire] = value;
    }
  }
  return input;
}

function unwrap(result: unknown): readonly Wire[] {
  if (Array.isArray(result)) {
    return result as Wire[];
  }
  if (typeof result === 'object' && result !== null && Array.isArray((result as { data?: unknown }).data)) {
    return (result as { data: Wire[] }).data;
  }
  return [];
}

function codeOf(error: unknown): string | null {
  const code = typeof error === 'object' && error !== null ? (error as { code?: unknown }).code : undefined;
  return typeof code === 'string' ? code : null;
}

/** The only place the Screens call Tools: camelCase in, camelCase rows out. */
@Injectable()
export class ItnTools {
  private readonly context = injectPackageContext();

  private async call(tool: ItnTool, args: Readonly<Record<string, unknown>> = {}): Promise<readonly Wire[]> {
    try {
      return unwrap(await this.context().tools.call<unknown>(tool, buildInput(tool, args)));
    } catch (error) {
      const message = error instanceof Error ? error.message : String(error);
      throw new ItnToolError(tool, codeOf(error), message);
    }
  }

  private async rows<T>(tool: ItnTool, args: Readonly<Record<string, unknown>>, dates: readonly string[]): Promise<readonly T[]> {
    return (await this.call(tool, args)).map((row) => mapRow(row, dates) as T);
  }

  findActs(a: { q?: string | undefined; collection?: string | undefined; limit: number; offset: number }): Promise<readonly ActRow[]> {
    return this.rows(ItnTool.ActsFind, a, ACT_DATES);
  }

  ingestStatus(): Promise<readonly StatusRow[]> {
    return this.rows(ItnTool.IngestStatus, {}, STATUS_DATES);
  }

  actOutline(a: { urn: string; limit: number; offset: number }): Promise<readonly OutlineRow[]> {
    return this.rows(ItnTool.ActOutline, a, []);
  }

  /** The commi of one article, in the legal order the Tool returns. */
  article(urn: string): Promise<readonly CommaRow[]> {
    return this.rows(ItnTool.Article, { urn }, []);
  }

  actVersions(actUrn: string): Promise<readonly VersionRow[]> {
    return this.rows(ItnTool.ActVersions, { actUrn }, VERSION_DATES);
  }

  /** Slice 0 of length 1: only the document identity (total_length, sha256, version_date), never the XML. */
  async aknMeta(actUrn: string): Promise<AknMeta | null> {
    const [row] = await this.rows<AknMeta>(ItnTool.ActAkn, { actUrn, offset: 0, length: 1 }, AKN_DATES);
    return row ?? null;
  }
}
