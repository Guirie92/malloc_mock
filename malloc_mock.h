/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   malloc_mock.h                                      :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: guillsan <guillsan@student.42madrid.com    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/10/31 22:09:02 by guillsan          #+#    #+#             */
/*   Updated: 2025/10/31 23:39:25 by guillsan         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#ifndef MALLOC_MOCK_H
# define MALLOC_MOCK_H

void	set_malloc_fail_at(int nth_one_based);
void	reset_malloc_mock(void);
void	malloc_set_null(int nth);

#define malloc(size) fail_malloc(size)
		
#endif /* MALLOC_MOCK_H */