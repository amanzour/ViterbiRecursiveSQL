import numpy as np

O = np.array([0, 1, 2], dtype=int)
S = np.array([0, 1], dtype=int)
PI = np.array([0.5, 0.5])
Y = np.array([2, 2, 2, 0, 2, 1], dtype=int)
A = np.array([[0.75, 0.25],[0.4, 0.6]])
B = np.array([[0.33, 0.54, 0.1],[0.5, 0.25, 0.25]])


T_1 = np.zeros((len(S),len(Y)), dtype=float)
T_2 = np.zeros((len(S),len(Y)), dtype=int)


for i in range(len(S)):
    T_1[i,0] = PI[i]*B[i,Y[0]]
    T_2[i,0] = -1

for j in range(1,len(Y)):
    for i in range(len(S)):
        curval=0
        curk = -1
        for k in range(len(S)):   
            if T_1[k,j-1]*A[k,i]*B[i,Y[j]] > curval:
                curval = T_1[k,j-1]*A[k,i]*B[i,Y[j]]
                curk = k
        T_1[i,j] = curval
        T_2[i,j] = curk


X = np.zeros(len(Y), dtype=int)
X[-1] = np.argmax(T_1[:,-1])

for j in range(len(Y)-1,0,-1):
    X[j-1] = T_2[X[j],j]

print("X =" + str(X))