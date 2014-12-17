/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package distributedcoxwithhe;

import java.util.logging.Level;
import java.util.logging.Logger;
import parallelComputing.CurrentParallelWork;
import thep.paillier.EncryptedInteger;
import thep.paillier.PrivateKey;
import thep.paillier.PublicKey;
import thep.paillier.exceptions.BigIntegerClassNotValid;
import thep.paillier.exceptions.PublicKeysNotEqualException;
//centric version 

public class JAVA_HM_Matrix implements CurrentParallelWork {

    EncryptedInteger[][] enc_matrix;
    PublicKey publicKey = null;
    PrivateKey privateKey = null;
    String[][] raw_matrix;
    String[] dec_matrix;
    EncryptedInteger[][] matrix1;
    EncryptedInteger[][] matrix2;
    String currentMethod = null;
    int currentWorkLength = 0;
    int wordLength = 0;

    // for encrypt
    public JAVA_HM_Matrix(PublicKey publicKey, String[][] raw_matrix, String currentMethod) {
        this.publicKey = publicKey;
        this.raw_matrix = raw_matrix;
        this.currentMethod = currentMethod;
        this.currentWorkLength = raw_matrix.length;
        this.enc_matrix = new EncryptedInteger[this.currentWorkLength][raw_matrix[0].length];
    }

    // for pairwise sum
    public JAVA_HM_Matrix(EncryptedInteger[][] matrix1, EncryptedInteger[][] matrix2, String currentMethod) {
        this.matrix1 = matrix1;
        this.matrix2 = matrix2;
        this.currentMethod = currentMethod;
        this.currentWorkLength = matrix1.length;
        this.enc_matrix = new EncryptedInteger[this.currentWorkLength][matrix1[0].length];
    }

    // for decrypt
    public JAVA_HM_Matrix(PrivateKey privateKey, EncryptedInteger[][] matrix1, int wordLength, String currentMethod) {
        this.privateKey = privateKey;
        this.matrix1 = matrix1;
        this.currentMethod = currentMethod;
        this.currentWorkLength = matrix1.length;
        this.wordLength = wordLength;
        this.dec_matrix = new String[this.currentWorkLength];
    }

    public static void main(String[] args) {

    }
/////////////////////

    public static String[] decryptMatrix(PrivateKey privateKey, EncryptedInteger[][] matrix1, int wordLength) throws BigIntegerClassNotValid {
        int m = matrix1.length;
        int n = matrix1[0].length;
        String[] dec_matrix = new String[m];
        for (int i = 0; i < m; i++) {
            dec_matrix[i] = new String();
            for (int j = 0; j < n; j++) {
                dec_matrix[i] = String.format("%s %" + wordLength + "s", dec_matrix[i], matrix1[i][j].decrypt(privateKey).toString());
            }
        }
        return dec_matrix;
    }

    public void decryptMatrix_parallel(int i) throws BigIntegerClassNotValid {
        int n = matrix1[0].length;
        dec_matrix[i] = new String();
        for (int j = 0; j < n; j++) {
            dec_matrix[i] = String.format("%s %" + wordLength + "s", dec_matrix[i], matrix1[i][j].decrypt(privateKey).toString());
        }
    }

/////////////////////
    public static EncryptedInteger[][] encryptMatrix(PublicKey publicKey, String[][] raw_matrix) throws BigIntegerClassNotValid {
        int m = raw_matrix.length;
        int n = raw_matrix[0].length;
        EncryptedInteger[][] enc_matrix = new EncryptedInteger[m][n];
        for (int i = 0; i < m; i++) {
            for (int j = 0; j < n; j++) {
                enc_matrix[i][j] = new EncryptedInteger(publicKey);
                enc_matrix[i][j].set(new java.math.BigInteger(raw_matrix[i][j]));
            }
        }
        return enc_matrix;
    }

    public void encryptMatrix_parallel(int i) throws BigIntegerClassNotValid {
        int n = enc_matrix[0].length;
        for (int j = 0; j < n; j++) {
            enc_matrix[i][j] = new EncryptedInteger(publicKey);
            enc_matrix[i][j].set(new java.math.BigInteger(raw_matrix[i][j]));
        }
    }
/////////////////////////////////////

    public static EncryptedInteger[][] secureMatrixPairwiseSum(EncryptedInteger[][] matrix1, EncryptedInteger[][] matrix2) throws PublicKeysNotEqualException {
        int m = matrix1.length;
        int n = matrix1[0].length;
        EncryptedInteger[][] enc_matrix = new EncryptedInteger[m][n];
        for (int i = 0; i < m; i++) {
            for (int j = 0; j < n; j++) {
                enc_matrix[i][j] = matrix1[i][j].add(matrix2[i][j]);
            }
        }
        return enc_matrix;
    }

    public void secureMatrixPairwiseSum_parallel(int i) throws PublicKeysNotEqualException {
        int n = matrix1[0].length;
        for (int j = 0; j < n; j++) {
            enc_matrix[i][j] = matrix1[i][j].add(matrix2[i][j]);
        }
    }

    @Override
    public void performWork(int workerID) {
        try {
            FunctionList p = FunctionList.valueOf(currentMethod);
            switch (p) {
                case encryptMatrix:
                    encryptMatrix_parallel(workerID);
                    break;
                case secureMatrixPairwiseSum:
                    secureMatrixPairwiseSum_parallel(workerID);
                    break;
                case decryptMatrix:
                    decryptMatrix_parallel(workerID);
                    break;
                default:
                    break;
            }
        } catch (BigIntegerClassNotValid ex) {
            Logger.getLogger(JAVA_HM_Matrix.class.getName()).log(Level.SEVERE, null, ex);
        } catch (PublicKeysNotEqualException ex) {
            Logger.getLogger(JAVA_HM_Matrix.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    public enum FunctionList {

        encryptMatrix,
        secureMatrixPairwiseSum,
        decryptMatrix
    }

    public EncryptedInteger[][] getEnc_matrix() {
        return enc_matrix;
    }

    public void setEnc_matrix(EncryptedInteger[][] enc_matrix) {
        this.enc_matrix = enc_matrix;
    }

    public PublicKey getPublicKey() {
        return publicKey;
    }

    public void setPublicKey(PublicKey publicKey) {
        this.publicKey = publicKey;
    }

    public String[][] getRaw_matrix() {
        return raw_matrix;
    }

    public void setRaw_matrix(String[][] raw_matrix) {
        this.raw_matrix = raw_matrix;
    }

    public EncryptedInteger[][] getMatrix1() {
        return matrix1;
    }

    public void setMatrix1(EncryptedInteger[][] matrix1) {
        this.matrix1 = matrix1;
    }

    public EncryptedInteger[][] getMatrix2() {
        return matrix2;
    }

    public void setMatrix2(EncryptedInteger[][] matrix2) {
        this.matrix2 = matrix2;
    }

    @Override
    public int getCurrentWorkLength() {
        return currentWorkLength;
    }

    public void setCurrentWorkLength(int currentWorkLength) {
        this.currentWorkLength = currentWorkLength;
    }

    public String getCurrentMethod() {
        return currentMethod;
    }

    public void setCurrentMethod(String currentMethod) {
        this.currentMethod = currentMethod;
    }

    public String[] getDec_matrix() {
        return dec_matrix;
    }

    public void setDec_matrix(String[] dec_matrix) {
        this.dec_matrix = dec_matrix;
    }

    public PrivateKey getPrivateKey() {
        return privateKey;
    }

    public void setPrivateKey(PrivateKey privateKey) {
        this.privateKey = privateKey;
    }

    public int getWordLength() {
        return wordLength;
    }

    public void setWordLength(int wordLength) {
        this.wordLength = wordLength;
    }

}
