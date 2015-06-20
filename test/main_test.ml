open OUnit
open Main

let _ = run_test_tt_main begin "1" >::: [
    "fib" >:: begin fun () ->
        assert_equal 3 (fib(3))
    end
] end
