/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package parallelComputing;

/**
 *
 * @author wsasyz
 */
public class MyMath {
    public static int[] linspaceInt(int d1, int d2, int _n) {
        int n = _n > d2 ? d2 + 1 : _n;
        if (n < 2) {
            int[] res = new int[_n];
            res[0] = d2;
            return res;
        } else if (n == 2) {
            int[] res = new int[_n];
            res[0] = d1;
            res[1] = d2;
            return res;
        } else {
            int[] res = new int[_n];
            res[0] = d1;
            res[n - 1] = d2;
            for (int i = 1; i <= n - 2; i++) {
                res[i] = (int) (d1 + i * (d2 - d1) / (n - 1));
            }
            return res;
        }
    }
}
