/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   malloc_mock.c                                      :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: guillsan <guillsan@student.42madrid.com    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/10/31 20:30:28 by guillsan          #+#    #+#             */
/*   Updated: 2025/10/31 20:53:10 by guillsan         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#define _GNU_SOURCE
#include <dlfcn.h>
#include <errno.h>
#include <stdlib.h>
#include <stdatomic.h>
#include <stdio.h>
#include <limits.h>

static atomic_int call_count = 0;
static int fail_at = -1;
static void *(*real_malloc)(size_t) = NULL;

static void	ensure_real_malloc(void)
{
	if (real_malloc)
		return ;
	/* RTLD_NEXT finds the next malloc symbol (the real libc one) */
	real_malloc = (void *(*)(size_t))dlsym(RTLD_NEXT, "malloc");
}

/* read env var at library load time */
__attribute__((constructor))
static void	init_fail_at(void)
{
	const char	*env;

	env = getenv("MALLOC_FAIL_AT");
	if (env)
	{
		/* interpret empty or invalid as -1 (never fail) */
		long v = strtol(env, NULL, 10);
		if (v > 0 && v <= INT_MAX)
			fail_at = (int)v;
	}
}

void	set_malloc_fail_at(int nth_one_based)
{
	fail_at = nth_one_based;
	atomic_store(&call_count, 0);
}

void	reset_malloc_mock(void)
{
	fail_at = -1;
	atomic_store(&call_count, 0);
}

/* interposed malloc */
void	*malloc(size_t size)
{
	int	n;

	n = atomic_fetch_add(&call_count, 1) + 1; /* 1-based call index */
	if (fail_at > 0 && n == fail_at)
	{
		errno = ENOMEM;
		/* simulate failure without allocating */
		return (NULL);
	}

	ensure_real_malloc();
	if (!real_malloc)
	{
		/* fallback: if we couldn't resolve real malloc, behave as ENOMEM */
		errno = ENOMEM;
		return (NULL);
	}
	return (real_malloc(size));
}
