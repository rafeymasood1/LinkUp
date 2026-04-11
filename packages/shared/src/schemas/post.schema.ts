import { z } from 'zod';

export const CreatePostSchema = z.object({
  content: z.string().min(1).max(500),
  mediaUrl: z.string().url().optional(),
});

export const PostResponseSchema = z.object({
  id: z.string().uuid(),
  content: z.string(),
  authorId: z.string().uuid(),
  createdAt: z.string().datetime(),
  likesCount: z.number().int().nonnegative(),
});

export type CreatePostInput = z.infer<typeof CreatePostSchema>;
export type PostResponse = z.infer<typeof PostResponseSchema>;
