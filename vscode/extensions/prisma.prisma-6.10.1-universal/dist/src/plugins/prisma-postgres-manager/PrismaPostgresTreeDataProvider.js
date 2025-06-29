"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.PrismaPostgresTreeDataProvider = void 0;
const vscode = __importStar(require("vscode"));
class PrismaPostgresTreeDataProvider {
    constructor(ppgRepository) {
        this.ppgRepository = ppgRepository;
        this.onDidChangeTreeData = ppgRepository.refreshEventEmitter.event;
    }
    getTreeItem(element) {
        switch (element.type) {
            case 'localRoot':
                return new PrismaLocalDatabasesItem();
            case 'remoteRoot':
                return new PrismaRemoteDatabasesItem();
            case 'workspace':
                return new PrismaWorkspaceItem(element.name, element.id);
            case 'project':
                return new PrismaProjectItem(element.name, element.id, element.workspaceId);
            case 'remoteDatabase':
                return new PrismaRemoteDatabaseItem(element.name, element.region, element.id, element.projectId, element.workspaceId);
            case 'localDatabase':
                return new PrismaLocalDatabaseItem(element);
        }
    }
    getChildren(element) {
        return __awaiter(this, void 0, void 0, function* () {
            if (!element) {
                if (yield this.shouldShowLoginWelcome()) {
                    yield vscode.commands.executeCommand('setContext', 'prisma.showLoginWelcome', true);
                    yield vscode.commands.executeCommand('setContext', 'prisma.showCreateDatabaseWelcome', false);
                    return [];
                }
                else if (yield this.shouldShowCreateDatabaseWelcome()) {
                    yield vscode.commands.executeCommand('setContext', 'prisma.showLoginWelcome', false);
                    yield vscode.commands.executeCommand('setContext', 'prisma.showCreateDatabaseWelcome', true);
                    return [];
                }
                else {
                    yield vscode.commands.executeCommand('setContext', 'prisma.showLoginWelcome', false);
                    yield vscode.commands.executeCommand('setContext', 'prisma.showCreateDatabaseWelcome', false);
                    return [{ type: 'localRoot' }, { type: 'remoteRoot' }];
                }
            }
            switch (element.type) {
                case 'localRoot':
                    return this.ppgRepository.getLocalDatabases();
                case 'remoteRoot':
                    return yield this.ppgRepository.getWorkspaces();
                case 'workspace':
                    return yield this.ppgRepository.getProjects({ workspaceId: element.id });
                case 'project':
                    return yield this.ppgRepository.getRemoteDatabases({
                        workspaceId: element.workspaceId,
                        projectId: element.id,
                    });
                case 'remoteDatabase':
                    return [];
                case 'localDatabase':
                    return [];
            }
        });
    }
    shouldShowLoginWelcome() {
        return __awaiter(this, void 0, void 0, function* () {
            return (yield this.ppgRepository.getWorkspaces()).length === 0;
        });
    }
    shouldShowCreateDatabaseWelcome() {
        return __awaiter(this, void 0, void 0, function* () {
            const res = yield Promise.all((yield this.ppgRepository.getWorkspaces()).map((w) => __awaiter(this, void 0, void 0, function* () { return yield this.ppgRepository.getProjects({ workspaceId: w.id }); })));
            return res.flat().length === 0;
        });
    }
}
exports.PrismaPostgresTreeDataProvider = PrismaPostgresTreeDataProvider;
class PrismaLocalDatabasesItem extends vscode.TreeItem {
    constructor() {
        super('Local Databases', vscode.TreeItemCollapsibleState.Expanded);
        this.id = 'local-root';
        this.iconPath = new vscode.ThemeIcon('device-desktop');
        this.contextValue = 'prismaLocalDatabasesItem';
    }
}
class PrismaLocalDatabaseItem extends vscode.TreeItem {
    constructor(element) {
        const { id, name, url, pid, running } = element;
        super(name, vscode.TreeItemCollapsibleState.None);
        this.id = `local-database-${id}-${name}`;
        this.iconPath = new vscode.ThemeIcon('database');
        this.contextValue = running ? 'prismaLocalDatabaseItemStarted' : 'prismaLocalDatabaseItemStopped';
        this.command = {
            command: 'prisma.studio.launchForDatabase',
            title: 'Launch Prisma Studio',
            arguments: [{ type: 'local', id, name, url, pid }],
        };
    }
}
class PrismaRemoteDatabasesItem extends vscode.TreeItem {
    constructor() {
        super('Remote Databases', vscode.TreeItemCollapsibleState.Expanded);
        this.id = 'remote-root';
        this.iconPath = new vscode.ThemeIcon('cloud');
        this.contextValue = 'prismaRemoteDatabasesItem';
    }
}
class PrismaWorkspaceItem extends vscode.TreeItem {
    constructor(workspaceName, workspaceId) {
        super(workspaceName, vscode.TreeItemCollapsibleState.Expanded);
        this.workspaceName = workspaceName;
        this.workspaceId = workspaceId;
        this.id = `workspace-${this.workspaceId}`;
        this.iconPath = new vscode.ThemeIcon('folder');
        this.contextValue = 'prismaWorkspaceItem';
    }
}
class PrismaProjectItem extends vscode.TreeItem {
    constructor(projectName, projectId, workspaceId) {
        super(projectName, vscode.TreeItemCollapsibleState.Expanded);
        this.projectName = projectName;
        this.projectId = projectId;
        this.workspaceId = workspaceId;
        this.id = `project-${this.workspaceId}-${this.projectId}`;
        this.iconPath = new vscode.ThemeIcon('project');
        this.contextValue = 'prismaProjectItem';
    }
}
class PrismaRemoteDatabaseItem extends vscode.TreeItem {
    constructor(databaseName, region, databaseId, projectId, workspaceId) {
        super(databaseName, vscode.TreeItemCollapsibleState.None);
        this.databaseName = databaseName;
        this.region = region;
        this.databaseId = databaseId;
        this.projectId = projectId;
        this.workspaceId = workspaceId;
        this.id = `database-${this.workspaceId}-${this.projectId}-${this.databaseId}`;
        this.iconPath = new vscode.ThemeIcon('database');
        this.contextValue = 'prismaRemoteDatabaseItem';
        this.command = {
            command: 'prisma.studio.launchForDatabase',
            title: 'Launch Prisma Studio',
            arguments: [
                {
                    type: 'remote',
                    workspaceId: this.workspaceId,
                    projectId: this.projectId,
                    databaseId: this.databaseId,
                },
            ],
        };
        this.description = region ? `(${region})` : false;
    }
}
//# sourceMappingURL=PrismaPostgresTreeDataProvider.js.map