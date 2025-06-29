import createClient from 'openapi-fetch';
import type { paths } from './api';
export declare const createManagementAPIClient: (token: string, tokenRefreshHandler: () => Promise<{
    token: string;
}>) => createClient.Client<paths, `${string}/${string}`>;
