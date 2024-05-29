from skimage.data import brain
from skimage.transform import resize, rescale

import numpy as np
import torch, torch.nn as nn
import cv2

def cv2disp(win, ima, xp, yp, sc): cv2.imshow(win, rescale(ima, sc, False) *1.0/(np.max(ima)+1e-15)); cv2.moveWindow(win, xp, yp)
def np_to_00torch(np_array):   return torch.from_numpy(np_array).unsqueeze(0).unsqueeze(0)
def torch_to_np(torch_array):  return np.squeeze(torch_array.detach().cpu().numpy())
device  = torch.device("cuda:o" if torch.cuda.is_available() else "cpu"); print(device)

nxd = 128; disp_scale = 3
nrd = int(nxd * 1.42); nphi = int(nxd*1.42)

brainimage=brain()
true_object_np      = resize(brainimage[9,30:-1, :-30], (nxd,nxd), anti_aliasing=False)
true_object_torch   = np_to_00torch(true_object_np).to(device)
true_object_torch   = true_object_torch.float()


cv2disp("True", true_object_np, 0, 0, disp_scale)




#--------------------------------------Torch System Matrix----------------------------------------------
def make_torch_system_matrix(nxd, nrd, nphi):
    system_matrix = torch.zeros(nrd*nphi, nxd*nxd) # rows = num sino bins, cols = num image pixels
    for xv in range(nxd):
        for yv in range(nxd):
            for ph in range(nphi):
                yp = -(xv-(nxd*0.5)) * np.sin(ph*np.pi/nphi)+(yv-(nxd*0.5)) * np.cos(ph*np.pi/nphi)
                yp_bin=int(yp+nrd/2)
                system_matrix[yp_bin + ph*nrd, xv + yv*nxd] = 1.0
    return system_matrix


def fp_system_torch(image, sys_mat, nxd, nrd, nphi):
    fp =  torch.reshape(image, (nxd*nxd,1))
    fb = torch.mm(sys_mat, fp)
    return torch.reshape(fb, (nphi, nrd))
def bp_system_torch(sino, sys_mat, nxd, nrd, nphi):
    return torch.reshape(torch.mm(sys_mat.T, torch.reshape(sino, (nrd*nphi,1))), (nxd,nxd))



sys_mat  = make_torch_system_matrix(nxd, nrd, nphi).to(device)


true_sinogram_torch  = fp_system_torch(true_object_torch, sys_mat, nxd, nrd, nphi)


cv2disp("Sinogram", torch_to_np(true_sinogram_torch), disp_scale*nxd, 0, disp_scale)



#------------------------------------------End FP---------------------------------------------------


#######################################CNN##########################################################

class CNN(nn.Module):
    def __init__(self, num_channels):
        super(CNN, self).__init__()
        self.CNN = nn.Sequential(
            nn.Conv2d(1, num_channels, 3, padding=(1, 1), padding_mode='reflect'), nn.PReLU(),
            nn.Conv2d(num_channels, num_channels, 3, padding=(1, 1), padding_mode='reflect'), nn.PReLU(),
            nn.Conv2d(num_channels, num_channels, 3, padding=(1, 1), padding_mode='reflect'), nn.PReLU(),
            nn.Conv2d(num_channels, num_channels, 3, padding=(1, 1), padding_mode='reflect'), nn.PReLU(),
            nn.Conv2d(num_channels, num_channels, 3, padding=(1, 1), padding_mode='reflect'), nn.PReLU(),
            nn.Conv2d(num_channels, num_channels, 3, padding=(1, 1), padding_mode='reflect'), nn.PReLU(),
            nn.Conv2d(num_channels, num_channels, 3, padding=(1, 1), padding_mode='reflect'), nn.PReLU(),
            nn.Conv2d(num_channels, num_channels, 3, padding=(1, 1), padding_mode='reflect'), nn.PReLU(),
            nn.Conv2d(num_channels, 1, 3, padding=(1, 1), padding_mode='reflect'), nn.PReLU(),
        )
    def forward(self,x):
        x = torch.squeeze(self.CNN(x.unsqueeze(0).unsqueeze(0)))
        return x

cnn = CNN(32).to(device)

#######################################################################################################################


#-------------------------------------------FBP------------------------------------------------------------------------

class FBP_CNN_Net(nn.Module):
    def __init__(self, cnn, sino_for_reconstruction):
        super(FBP_CNN_Net, self).__init__()
        self.sino_ones = torch.ones_like(sino_for_reconstruction)
        self.sens_image = bp_system_torch(self.sino_ones, sys_mat, nxd, nrd, nphi)
        self.cnn = cnn
        self.prelu = nn.PReLU()

    def forward(self, sino_for_reconstruction):
        filtered_sino = self.cnn(sino_for_reconstruction)
        recon = bp_system_torch(filtered_sino, sys_mat, nxd, nrd, nphi) / (self.sens_image+1.0e-15)
        recon = self.prelu(recon)
        fpsino = fp_system_torch(recon, sys_mat, nxd, nrd, nphi)


        cv2disp("Filtered Sino", torch_to_np(filtered_sino), disp_scale*(nxd+nrd), 0, disp_scale)
        cv2disp("FBP", torch_to_np(recon), disp_scale*(nxd+nrd), disp_scale*nphi+30, disp_scale)
        cv2disp("FP Sino", torch_to_np(fpsino), disp_scale*(nxd+nrd+nphi), 0, disp_scale)
        cv2disp("Difference", torch_to_np(fpsino - sino_for_reconstruction), disp_scale*(nxd+nrd+nrd), disp_scale, sc= 0)
        cv2.waitKey(1)
        return recon, fpsino

fbpnet = FBP_CNN_Net(cnn, true_sinogram_torch).to(device)

#===========================================TRAINING OF THE NETWORK

loss_fun = nn.MSELoss()
optimiser = torch.optim.Adam(fbpnet.parameters(), lr = 1e-4)

train_loss = list()
epochs = 60000

for ep in range(epochs):
    fbp_recon, rec_fp = fbpnet(true_sinogram_torch)
    loss = loss_fun(rec_fp, torch.squeeze(true_sinogram_torch))
    train_loss.append(loss.item())
    loss.backward()
    optimiser.step()
    optimiser.zero_grad()
    print('Epoch %d Training loss = %f' % ( ep, train_loss[-1]))

