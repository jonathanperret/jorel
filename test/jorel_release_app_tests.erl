-module(jorel_release_app_tests).
-include_lib("eunit/include/eunit.hrl").

jorel_release_jorel_sample_test_() ->
  {"Build release 0.0.1 for Erlang app and upgrade to 0.0.2",
   {setup,
    fun() ->
        os:putenv("JOREL", ".jorel/jorel"),
        bucfile:make_dir(".tests")
    end,
    fun(_) ->
        os:unsetenv("JOREL"),
        bucfile:remove_recursive(".tests")
    end,
    [
     {timeout, 200,
      fun() ->
          ?assertEqual(ok, bucfile:make_dir(".tests/0.0.1")),
          ?assertEqual(ok, bucfile:copy("test_apps/0.0.1/jorel_sample", ".tests/0.0.1", [recursive])),
          ?assertEqual(ok, bucfile:make_dir(".tests/0.0.1/jorel_sample/.jorel")),
          ?assertEqual(ok, bucfile:copy("_build/default/bin/jorel", ".tests/0.0.1/jorel_sample/.jorel/jorel"))
      end}
     , {timeout, 200,
        fun() ->
            ?assertMatch({ok, _},
                         sh:sh("make jorel.release v=0.0.1",
                               [return_on_error, {cd, ".tests/0.0.1/jorel_sample"}]))
        end}
     , {timeout, 200,
        fun() ->
            ?assertMatch({error, {1, "Node 'jorel_sample@127.0.0.1' not responding to pings.\n"}},
                         sh:sh("_jorel/jorel_sample/bin/jorel_sample ping",
                               [return_on_error, {cd, ".tests/0.0.1/jorel_sample"}]))
        end}
     , {timeout, 200,
        fun() ->
            ?assertMatch({ok, []},
                         sh:sh("_jorel/jorel_sample/bin/jorel_sample start",
                               [return_on_error, {cd, ".tests/0.0.1/jorel_sample"}])),
            timer:sleep(1000)
        end}
     , {timeout, 200,
        fun() ->
            ?assertMatch({ok, "pong\n"},
                         sh:sh("_jorel/jorel_sample/bin/jorel_sample ping",
                               [return_on_error, {cd, ".tests/0.0.1/jorel_sample"}]))
        end}
     , {timeout, 200,
        fun() ->
            ?assertMatch({ok, []},
                         sh:sh("_jorel/jorel_sample/bin/jorel_sample stop",
                               [return_on_error, {cd, ".tests/0.0.1/jorel_sample"}]))
        end}
     , {timeout, 200,
        fun() ->
            ?assertMatch({error, {1, "Node 'jorel_sample@127.0.0.1' not responding to pings.\n"}},
                         sh:sh("_jorel/jorel_sample/bin/jorel_sample ping",
                               [return_on_error, {cd, ".tests/0.0.1/jorel_sample"}]))
        end}
     , {timeout, 200,
        fun() ->
            ?assertEqual(ok, bucfile:make_dir(".tests/0.0.2")),
            ?assertEqual(ok, bucfile:copy("test_apps/0.0.2/jorel_sample", ".tests/0.0.2", [recursive])),
            ?assertEqual(ok, bucfile:make_dir(".tests/0.0.2/jorel_sample/.jorel")),
            ?assertEqual(ok, bucfile:copy("_build/default/bin/jorel", ".tests/0.0.2/jorel_sample/.jorel/jorel")),
            ?assertEqual(ok, bucfile:copy(".tests/0.0.1/jorel_sample/_jorel", ".tests/0.0.2/jorel_sample", [recursive])),
            ?assertMatch({ok, _},
                         sh:sh("make jorel.release",
                               [return_on_error, {cd, ".tests/0.0.2/jorel_sample"}])),
            ?assertMatch({ok, _},
                         sh:sh("make jorel.relup",
                               [return_on_error, {cd, ".tests/0.0.2/jorel_sample"}])),
            ?assertMatch({ok, _},
                         sh:sh("make jorel.archive",
                               [return_on_error, {cd, ".tests/0.0.2/jorel_sample"}])),
            ?assertEqual(ok, bucfile:copy(".tests/0.0.2/jorel_sample/_jorel/jorel_sample/releases/jorel_sample-0.0.2.tar.gz",
                                          ".tests/0.0.1/jorel_sample/_jorel/jorel_sample/releases/jorel_sample-0.0.2.tar.gz"))
        end}
     , {timeout, 200,
        fun() ->
            ?assertMatch({error, {1, "Node 'jorel_sample@127.0.0.1' not responding to pings.\n"}},
                         sh:sh("_jorel/jorel_sample/bin/jorel_sample ping",
                               [return_on_error, {cd, ".tests/0.0.1/jorel_sample"}]))
        end}
     , {timeout, 200,
        fun() ->
            ?assertMatch({ok, []},
                         sh:sh("_jorel/jorel_sample/bin/jorel_sample start",
                               [return_on_error, {cd, ".tests/0.0.1/jorel_sample"}])),
            timer:sleep(1000)
        end}
     , {timeout, 200,
        fun() ->
            ?assertMatch({ok, "pong\n"},
                         sh:sh("_jorel/jorel_sample/bin/jorel_sample ping",
                               [return_on_error, {cd, ".tests/0.0.1/jorel_sample"}]))
        end}
     , {timeout, 200,
        fun() ->
            ?assertMatch({ok, "Release 0.0.2 not found, attempting to unpack releases/jorel_sample-0.0.2.tar.gz\n" ++
                          "Unpacked successfully: 0.0.2\nInstalled Release: 0.0.2\nMade release permanent: 0.0.2\n"},
                         sh:sh("_jorel/jorel_sample/bin/jorel_sample install 0.0.2",
                               [return_on_error, {cd, ".tests/0.0.1/jorel_sample"}]))
        end}
     , {timeout, 200,
        fun() ->
            ?assertMatch({ok, _},
                         sh:sh("_jorel/jorel_sample/bin/jorel_sample exec release_handler which_releases",
                               [return_on_error, {cd, ".tests/0.0.1/jorel_sample"}]))
        end}
     , {timeout, 200,
        fun() ->
            ?assertMatch({ok, []},
                         sh:sh("_jorel/jorel_sample/bin/jorel_sample stop",
                               [return_on_error, {cd, ".tests/0.0.1/jorel_sample"}]))
        end}
     , {timeout, 200,
        fun() ->
            ?assertMatch({error, {1, "Node 'jorel_sample@127.0.0.1' not responding to pings.\n"}},
                         sh:sh("_jorel/jorel_sample/bin/jorel_sample ping",
                               [return_on_error, {cd, ".tests/0.0.1/jorel_sample"}]))
        end}
    ]}}.
