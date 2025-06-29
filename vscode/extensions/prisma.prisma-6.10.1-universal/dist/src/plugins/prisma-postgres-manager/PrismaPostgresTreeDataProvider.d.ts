import * as vscode from 'vscode';
import { PrismaPostgresItem, PrismaPostgresRepository } from './PrismaPostgresRepository';
export declare class PrismaPostgresTreeDataProvider implements vscode.TreeDataProvider<PrismaPostgresItem> {
    private readonly ppgRepository;
    readonly onDidChangeTreeData: vscode.Event<PrismaPostgresItem | undefined | null | void>;
    constructor(ppgRepository: PrismaPostgresRepository);
    getTreeItem(element: PrismaPostgresItem): vscode.TreeItem;
    getChildren(element?: PrismaPostgresItem): Promise<PrismaPostgresItem[]>;
    shouldShowLoginWelcome(): Promise<boolean>;
    shouldShowCreateDatabaseWelcome(): Promise<boolean>;
}
