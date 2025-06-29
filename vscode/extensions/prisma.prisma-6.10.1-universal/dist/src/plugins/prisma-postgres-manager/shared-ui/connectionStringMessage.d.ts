type MessageType = 'databaseCreated' | 'connectionStringCreated' | 'connectionStringDisplay';
export declare const presentConnectionString: ({ connectionString, type, }: {
    connectionString: string;
    type: MessageType;
}) => Promise<void>;
export {};
