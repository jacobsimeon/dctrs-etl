# With Sidekiq

  # Multiple Processes
  65.19s user 5.84s system 370% cpu 19.166 total

  ##Multiple Processes, multiple threads

  ### 4 processes, 5 threads, sidekiq client size 5
  59.12s user 11.07s system 392% cpu 17.883 total

  ---

  # Single Process
  33.39s user 3.83s system 99% cpu 37.339 total

  ## Single Process, multiple threads
  ### 25 threads
  138.36s user 128.55s system 137% cpu 3:14.45 total

  ### 5 threads in pool, Sidekiq client size 1
  67.18s user 45.22s system 132% cpu 1:24.96 total

  ### 5 threads in pool, Sidekiq client size 5
  42.43s user 7.40s system 109% cpu 45.474 total

  ### 15 threads in pool, Sidekiq client size 15
  44.76s user 18.46s system 122% cpu 51.804 total

  ### 2 threads in pool, Sidekiq client size 25
  45.55s user 18.41s system 121% cpu 52.577 total

# Without Sidekiq

  # Single Process, 5 threads
  363.70s user 20.33s system 103% cpu 6:11.48 total

  # 4 Processes, 5 threads each
  430.59s user 18.85s system 405% cpu 1:50.83 total

  # 5 Processes, 5 threads each
  457.76s user 18.30s system 504% cpu 1:34.30 total

  # 8 Processes, 5 threads each
  531.49s user 2.25s system 751% cpu 1:11.05 total

  * 8 Processes, 10 threads each
  510.57s user 2.24s system 741% cpu 1:09.14 total

  # 9 Processes, 5 threads each
  493.05s user 2.01s system 762% cpu 1:04.93 total

  # 12 Processes, 50 threads each
  533.12s user 13.32s system 666% cpu 1:22.00 total

  # 12 Processes, 25 threads each
  485.31s user 13.23s system 659% cpu 1:15.57 total

  # 12 Processes, 5 threads each
  508.89s user 2.65s system 741% cpu 1:09.02 total

  # 13 Processes, 25 threads each
  478.90s user 2.12s system 770% cpu 1:02.44 total

  # 13 Processes, 1 thread each
  505.05s user 3.57s system 765% cpu 1:06.46 total

  # 13 Processes, no thread pool
  540.27s user 2.13s system 757% cpu 1:11.57 total


  # 13 Processes, 5 threads each
  478.90s user 2.12s system 770% cpu 1:02.44 total
  482.40s user 2.33s system 764% cpu 1:03.43 total
  516.90s user 2.62s system 732% cpu 1:10.91 total

  No output:
    503.18s user 2.25s system 735% cpu 1:08.72 total

  No output, no calculation:
    12.72s user 9.78s system 477% cpu 4.716 total (really fast)

  No output, csv parsing only:
    475.18s user 2.10s system 771% cpu 1:01.85 total

  # 20 Processes, 5 threads each
  457.91s user 2.59s system 769% cpu 59.810 total
