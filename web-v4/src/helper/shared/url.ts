import { env } from 'envs/env';

export function buildFileUrl(path?: string | null): string {
    if (!path) {
        return '';
    }

    if (/^(https?:)?\/\//i.test(path) || path.startsWith('data:') || path.startsWith('blob:')) {
        return path;
    }

    const base = env.FILE_BASE_URL.replace(/\/+$/, '');
    const cleanPath = path.replace(/^\/+/, '');

    return `${base}/${cleanPath}`;
}
