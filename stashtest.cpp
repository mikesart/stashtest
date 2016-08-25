#define __GNU_SOURCE
#include <stdio.h>
#include <chrono>

#include "git2.h"

// Timer routines. Use like:
//   util_time_t t0 = util_get_time();
//   printf( "%.2fms\n", util_time_to_ms( t0, util_get_time() );
typedef std::chrono::time_point< std::chrono::high_resolution_clock > util_time_t;

inline util_time_t util_get_time()
{
    return std::chrono::high_resolution_clock::now();
}
inline float util_time_to_ms( util_time_t start, util_time_t end )
{
    auto diff = end - start;
    return ( float )std::chrono::duration< double, std::milli >( diff ).count();
}

#define LIBGIT2_CHECK( _ret, _func, ... )                                              \
    do                                                                                 \
    {                                                                                  \
        util_time_t t0 = util_get_time();                                              \
        printf("Calling %s...\n", #_func);                                             \
        _ret = _func( __VA_ARGS__ );                                                   \
        printf("  %.2fms\n", util_time_to_ms(t0, util_get_time()));                    \
        if ( _ret )                                                                    \
            printf( "%s:%d %s failed: %d\n", __FILE__, __LINE__, #_func, _ret);        \
    } while ( 0 )

class GitSignature
{
public:
    GitSignature( git_repository *repo )
    {
        int giterr;

        LIBGIT2_CHECK( giterr, git_signature_default, &m_sig, repo );
        if ( giterr )
        {
            LIBGIT2_CHECK( giterr, git_signature_now, &m_sig, "unknown", "unknown" );
        }
    }

    ~GitSignature()
    {
        git_signature_free( m_sig );
        m_sig = NULL;
    }

public:
    git_signature *m_sig = NULL;
};

bool gitw_stash( git_repository *repo, const char *msg, unsigned int flags )
{
    int giterr = 0;
    GitSignature sig( repo );

    git_oid saved_stash;
    LIBGIT2_CHECK( giterr, git_stash_save, &saved_stash, repo, sig.m_sig, msg, flags );
    return !giterr;
}

int main( int argc, char **argv )
{
    int giterr;
    git_repository *repo = NULL;
    const char *repodir_in = (argc > 1) ? argv[1] : ".";

    // Init libgit2.
    git_libgit2_init();

    printf( "Opening repository '%s'\n", repodir_in );

    LIBGIT2_CHECK( giterr, git_repository_open_ext, &repo, repodir_in, 0, NULL );
    if ( !giterr )
    {
        unsigned int flags = GIT_STASH_KEEP_INDEX | GIT_STASH_INCLUDE_UNTRACKED;

        gitw_stash( repo, "stash test", flags );
    }

    git_libgit2_shutdown();
}
