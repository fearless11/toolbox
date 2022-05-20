package main

import (
	"context"
	"fmt"
	"net/http"
	_ "net/http/pprof"
	"sync"
	"time"
)

func main() {
	// http://127.0.0.1:8989/debug/pprof
	go http.ListenAndServe(":8989", nil)

	// goroutine 如何实现数据共享，如何控制并发
	goByChannel()
	goByWaitGroup()
	goByContext()

	time.Sleep(30 * time.Second)
}

// channel
func goByChannel() {
	fmt.Println("---goByChannel---")
	ch := make(chan struct{})
	go func() {
		fmt.Println("start work")
		time.Sleep(1 * time.Second)
		ch <- struct{}{}
	}()
	<-ch
}

// sync.WaitGroup
func goByWaitGroup() {
	fmt.Println("---goByWaitGroup---")
	var wg sync.WaitGroup
	for i := 0; i < 10; i++ {
		wg.Add(1)
		go func(n int) {
			fmt.Println(n)
			wg.Done()
		}(i)
	}
	wg.Wait() // 等待goroutine结束
}

// context 上下文环境
// 传递的自定义键类型，避免与作用域内置类型发生碰撞
type key string

var UseKey key

func goByContext() {
	fmt.Println("---goByContext---")
	// 启动一个根的上下文ctx
	ctx, cancel := context.WithCancel(context.Background())
	// 数据共享
	ctx = context.WithValue(ctx, UseKey, "hello")
	go func() {
		time.Sleep(3 * time.Second)
		// 当根ctx退出,子ctx收到Done信号
		cancel()
	}()
	printC1(ctx)
}

func printC1(ctx context.Context) {
	fmt.Println("printC1")
	v := ctx.Value(UseKey)
	go printC2(ctx)
	select {
	case <-ctx.Done():
		fmt.Printf("printC1 ctx.Done. value: %v\n", v)
	}
}

func printC2(ctx context.Context) {
	fmt.Println("printC2")
	v := ctx.Value(UseKey)
	select {
	case <-ctx.Done():
		fmt.Printf("printC2 ctx.Done. value: %v\n", v)
	}
}
