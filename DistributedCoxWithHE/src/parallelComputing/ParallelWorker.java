/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package parallelComputing;
/**
 *
 * @author wsasyz
 */
public class ParallelWorker extends Thread {       
    public CurrentParallelWork currentLDPCAWorker;
    public int [] parallelID;

    public ParallelWorker() {
        
    }
            
    public void performMTprocessing(int numofThreads, CurrentParallelWork currentLDPCAWorker) throws InterruptedException {        
        this.currentLDPCAWorker = currentLDPCAWorker;
        this.parallelID = MyMath.linspaceInt(0, currentLDPCAWorker.getCurrentWorkLength(), numofThreads + 1);
        initialThreads(numofThreads, this);
    }

    private static void initialThreads(int threadsNum, ParallelWorker parallelComputer) throws InterruptedException {
        Thread[] testArray = new Thread[threadsNum];
        for (int i = 0; i < threadsNum; i++) {
            testArray[i] = new Thread(parallelComputer);
            testArray[i].setName(String.format("band%d", i));
        }
        for (int i = 0; i < threadsNum; i++) {
            testArray[i].start();
        }
        for (int i = 0; i < threadsNum; i++) {
            testArray[i].join();
        }
    }

    @Override
    public void run() {
        String threadName = Thread.currentThread().getName();
        int id = Integer.parseInt(threadName.substring(4));
        for (int i = parallelID[id]; i < parallelID[id + 1]; i++) {
//            currentLDPCAWorker[i].setparentThreadName(threadName);
            currentLDPCAWorker.performWork(i);
        }
    }
}
