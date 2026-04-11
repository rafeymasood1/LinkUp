import { useMutation } from '@tanstack/react-query';
import { apiClient } from '@/lib/api-client';
import type { CreateUserInput, UserResponse } from '@myapp/shared';

export function useRegister() {
  return useMutation({
    mutationFn: (data: CreateUserInput) =>
      apiClient.post<UserResponse>('/auth/register', data),
  });
}
