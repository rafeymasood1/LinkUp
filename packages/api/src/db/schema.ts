import { pgTable, uuid, varchar, text, timestamp, integer } from 'drizzle-orm/pg-core';

export const users = pgTable('users', {
  id: uuid('id').defaultRandom().primaryKey(),
  email: varchar('email', { length: 255 }).notNull().unique(),
  username: varchar('username', { length: 30 }).notNull().unique(),
  passwordHash: varchar('password_hash', { length: 255 }).notNull(),
  createdAt: timestamp('created_at').defaultNow().notNull(),
  updatedAt: timestamp('updated_at').defaultNow().notNull(),
});

export const posts = pgTable('posts', {
  id: uuid('id').defaultRandom().primaryKey(),
  content: text('content').notNull(),
  authorId: uuid('author_id').references(() => users.id).notNull(),
  mediaUrl: varchar('media_url', { length: 500 }),
  likesCount: integer('likes_count').default(0).notNull(),
  createdAt: timestamp('created_at').defaultNow().notNull(),
});

export const follows = pgTable('follows', {
  followerId: uuid('follower_id').references(() => users.id).notNull(),
  followingId: uuid('following_id').references(() => users.id).notNull(),
  createdAt: timestamp('created_at').defaultNow().notNull(),
});
