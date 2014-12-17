/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package parallelComputing;

/**
 *
 * @author wsasyz
 */
public interface CurrentParallelWork{        
    public void performWork(int workerID);  
    public int getCurrentWorkLength();
    //public DecodeResults getDecodeResults();
//    public void setparentThreadName(String parentThreadName);
}
