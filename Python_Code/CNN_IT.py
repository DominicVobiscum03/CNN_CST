from skimage.data import brain
from skimage.transform import resize, rescale

import numpy as np
import torch, torch.nn as nn
import cv2

device  = torch.device("cuda:o" if torch.cuda.is_available() else "cpu"); print(device)


def cv2disp(win, ima, xp, yp, sc): cv2.imshow(win, rescale(ima, sc, False) *1.0/(np.max(ima)+1e-15)); cv2.moveWindow(win, xp, yp)

def np_to_00torch(np_array):   return torch.from_numpy(np_array).unsqueeze(0).unsqueeze(0)
def torch_to_np(torch_array):  return np.squeeze(torch_array.detach().cpu().numpy())



nxd= 128; disp_scale = 4
nrd = int(nxd*1.42); nphi = nrd

brainimage=brain()
true_object_np      = resize(brainimage[5,30:-1, :-30], (nxd,nxd), anti_aliasing=False)
true_object_torch   = np_to_00torch(true_object_np).to(device)


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
sys_mat = sys_mat.to(torch.float64)


true_sinogram_torch  = fp_system_torch(true_object_torch, sys_mat, nxd, nrd, nphi)


cv2disp("Sinogram", torch_to_np(true_sinogram_torch), disp_scale*nxd, 0, disp_scale)




#---------------------------------------MLEM-------------------------------------------------

class MLEM_Net(nn.Module):
    def __init__(self, sino_for_reconstruction, num_its):
        super(MLEM_Net, self).__init__()
        self.num_its = num_its
        self.sino_ones = torch.ones_like(sino_for_reconstruction)
        self.sens_image = bp_system_torch(self.sino_ones, sys_mat, nxd, nrd, nphi)
    def forward(self, sino_for_reconstruction):
        recon = torch.ones(nxd,nxd).to(device)
        recon = recon.to(torch.float64)
        for it in range(self.num_its):
            fpsino = fp_system_torch(recon, sys_mat, nxd, nrd, nphi);
            ratio = sino_for_reconstruction / (fpsino +1.0e-9)
            correction = bp_system_torch(ratio, sys_mat, nxd, nrd, nphi) / (self.sens_image+1.0e-9)
            recon = recon * correction
            cv2disp("MLEM", torch_to_np(recon), 0, disp_scale*nxd+15, disp_scale)
            cv2disp("FP", torch_to_np(fpsino), disp_scale*nxd, disp_scale*nxd+15, disp_scale)
            cv2disp("Ratio", torch_to_np(ratio), disp_scale*(nxd+nrd), 0, disp_scale)
            cv2disp("Correction", torch_to_np(correction), disp_scale*(nxd+nrd), disp_scale*nxd+15, disp_scale)
            print("MLEM", it)
            cv2.waitKey(1)
        return recon

core_iterations = 2

deepnet = MLEM_Net(true_sinogram_torch, core_iterations).to(device)
mlem_recon = deepnet(true_sinogram_torch)

cv2disp("MLEM REF", torch_to_np(mlem_recon), disp_scale*nxd, 0, disp_scale)

class CNN(nn.Module):
    def __init__(self):
        super(CNN,self).__init__()
        self.CNN = nn.Sequential(
            nn.Conv2d(1,8,7,padding=(3,3)), nn.PReLU(),
            nn.Conv2d(8,8,7,padding=(3,3)), nn.PReLU(),
            nn.Conv2d(8,8,7,padding=(3,3)), nn.PReLU(),
            nn.Conv2d(8,8,7,padding=(3,3)), nn.PReLU(),
            nn.Conv2d(8,1,7,padding=(3,3)), nn.PReLU(),
        )
    def forward(self, x):
        x = torch.squeeze(self.CNN(x.unsqueeze(0).unsqueeze(0)))
        x = x.to(torch.float64)
        return x

cnn = CNN().to(device)


class MLEM_CNN_Net(nn.Module):
    def __init__(self, cnn, sino_for_reconstruction, num_its):
        super(MLEM_CNN_Net, self).__init__()
        self.num_its = num_its
        self.sino_ones = torch.ones_like(sino_for_reconstruction)
        self.sens_image = bp_system_torch(self.sino_ones, sys_mat, nxd, nrd, nphi)
        self.cnn = cnn
    def forward(self, sino_for_reconstruction):
        recon = torch.ones(nxd,nxd).to(device)
        recon = recon.to(torch.float64)
        for it in range(self.num_its):
            fpsino = fp_system_torch(recon, sys_mat, nxd, nrd, nphi);
            ratio = sino_for_reconstruction / (fpsino +1.0e-9)
            correction = bp_system_torch(ratio, sys_mat, nxd, nrd, nphi) / (self.sens_image+1.0e-9)
            recon = recon * correction
            #Inter Update cnn
            recon = torch.abs(recon + self.cnn(recon))
            cv2disp("MLEM", torch_to_np(recon), 0, disp_scale*nxd+15, disp_scale)
            cv2disp("FP", torch_to_np(fpsino), disp_scale*nxd, disp_scale*nxd+15, disp_scale)
            cv2disp("Ratio", torch_to_np(ratio), disp_scale*(nxd+nrd), 0, disp_scale)
            cv2disp("Correction", torch_to_np(correction), disp_scale*(nxd+nrd), disp_scale*nxd+15, disp_scale)
            print("MLEM", it)
            cv2.waitKey(1)
        return recon

cnnmlem = MLEM_CNN_Net(cnn, true_sinogram_torch, core_iterations).to(device)
mlemcnn_recon = cnnmlem(true_sinogram_torch)

cv2.waitKey(0)