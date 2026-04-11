import { z } from 'zod';

export const CreateUserSchema = z.object({
  email: z.string().email('Invalid email format'),
  username: z.string().min(3).max(30).regex(/^[a-zA-Z0-9_]+$/),
  password: z.string().min(8, 'Password must be at least 8 characters'),
});

export const UserResponseSchema = z.object({
  id: z.string().uuid(),
  email: z.string().email(),
  username: z.string(),
  createdAt: z.string().datetime(),
});

export type CreateUserInput = z.infer<typeof CreateUserSchema>;
export type UserResponse = z.infer<typeof UserResponseSchema>;
