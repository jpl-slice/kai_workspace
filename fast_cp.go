package main

import (
	"bufio"
	"math/rand"
	"os"
	"path/filepath"
	"sync"
	"time"
)

func main() {
	// Set the source directory
	srcDir := "ILSVRC2012/train/"

	// Set the destination directory
	destDir := "combined-msl-250k-imagenet-250k/ImageNet/"

	// Set the number of files to copy
	numFiles := 250000

	// Create a slice to store the file names
	files := make([]string, 0)

	// Walk the source directory and get a list of all the files
	filepath.Walk(srcDir, func(path string, info os.FileInfo, err error) error {
		if !info.IsDir() {
			files = append(files, path)
		}
		return nil
	})

	// Seed the random number generator
	rand.Seed(time.Now().UnixNano())

	// Use a wait group to keep track of the number of copying routines
	var wg sync.WaitGroup

	// Copy the specified number of random files
	for i := 0; i < numFiles; i++ {
		wg.Add(1)

		go func() {
			// Get a random file
			randIndex := rand.Intn(len(files))
			randFile := files[randIndex]

			// Create the destination file path
			destPath := filepath.Join(destDir, filepath.Base(randFile))

			// Copy the file using buffered I/O
			src, err := os.Open(randFile)
			if err != nil {
				wg.Done()
				return
			}
			defer src.Close()

			dest, err := os.Create(destPath)
			if err != nil {
				wg.Done()
				return
			}
			defer dest.Close()

			bufSrc := bufio.

