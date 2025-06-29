"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.createManagementAPIClient = void 0;
const openapi_fetch_1 = __importDefault(require("openapi-fetch"));
class FetchError extends Error {
    constructor() {
        super('Connection to API failed.');
    }
}
/**
 * Creates a fetch function that includes the given `initialToken` in the auth header.
 * This fetch function automatically detects expired tokens and refreshes them using the given `tokenRefreshHandler`.
 * It buffers all requests until the token is refreshed.
 *
 * @param initialToken - The initial token to use.
 * @param tokenRefreshHandler - The function to call to refresh the token.
 * @returns A fetch function that refreshes the token when it expires.
 */
const createTokenRefreshingFetch = (initialToken, tokenRefreshHandler) => {
    let currentToken = initialToken;
    let refreshPromise = null;
    let subscribers = [];
    const isRefreshing = () => refreshPromise !== null;
    const refreshAccessToken = () => __awaiter(void 0, void 0, void 0, function* () {
        if (isRefreshing()) {
            console.log('token refresh already in progress, waiting for it to complete...');
            return new Promise((resolve) => subscribers.push(resolve));
        }
        refreshPromise = tokenRefreshHandler().finally(() => {
            refreshPromise = null;
        });
        const { token } = yield refreshPromise;
        console.log('refreshed token!');
        currentToken = token;
        subscribers.forEach((cb) => cb(token));
        subscribers = [];
        return token;
    });
    return function tokenRefreshingFetch(request) {
        return __awaiter(this, void 0, void 0, function* () {
            const requestCloneForRetry = request.clone();
            request.headers.set('Authorization', `Bearer ${currentToken}`);
            let response = yield fetch(request);
            if (response.status === 401) {
                console.log('detected expired token, refreshing...');
                yield refreshAccessToken();
                requestCloneForRetry.headers.set('Authorization', `Bearer ${currentToken}`);
                response = yield fetch(requestCloneForRetry);
            }
            return response;
        });
    };
};
const createManagementAPIClient = (token, tokenRefreshHandler) => {
    const client = (0, openapi_fetch_1.default)({
        baseUrl: 'https://api.prisma.io',
        fetch: createTokenRefreshingFetch(token, tokenRefreshHandler),
    });
    client.use({
        onRequest({ request }) {
            console.log('onRequest', {
                method: request.method,
                url: request.url,
                body: request.body,
            });
            return request;
        },
        onResponse({ response }) {
            console.log('onResponse', {
                status: response.status,
                statusText: response.statusText,
                url: response.url,
            });
            return response;
        },
        onError({ error }) {
            console.error('Fetch error', error);
            return new FetchError();
        },
    });
    return client;
};
exports.createManagementAPIClient = createManagementAPIClient;
//# sourceMappingURL=client.js.map