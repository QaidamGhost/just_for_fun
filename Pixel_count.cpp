#include "stdio.h"
#include "windows.h"

//对花岗岩块样进行染色，使石英、斜长石、碱性长石呈现不同的颜色（分别呈灰白色、红色、黄色）。
//拍摄染色后的照片并重采样，数据格式为8位256色bmp。重命名为1.bmp并存放于逻辑盘E盘的根目录下。
//运行后输出记录计数器情况的txt文件，可以用SPSS对RGB值进行聚类分析并统计类别数量。
//剔除其他暗色矿物，计算QAF三个端元的面积占比。

char TextStr[100];//报错消息
int Pixel_list[256];//像素计数器

bool _fastcall ReadBmpBy_8BitFileFunc(FILE *fio,FILE *fou,BITMAPFILEHEADER bmfh,BITMAPINFOHEADER bmih,RGBQUAD rgb)
{
	//变量定义
	DWORD offBits = bmfh.bfOffBits;	//文件头至像素数据间的距离
	LONG nWidt = bmih.biWidth;	//图片宽度
	LONG nHeig = bmih.biHeight;	//图片高度
	byte *temp = new byte[1024];	//用于读取调色板
	FILE *fo2=fopen("E:\\color_table.txt","w");	//调色板输出txt
	if(!fo2)
	{
		printf("txt文件打开错误！");
		return 0;
	}
	int datype = 1;	//256色每个像素1字节
	long len = nWidt*nHeig*datype;	//像素数据字节数
	char *Mdata = new char[len+1];	//用于读取像素数据
	if(!Mdata)
	{
		strcpy(TextStr,"内存错误！");
		return false;
	}
	long kk,jj;	//循环变量
	UCHAR ch;	//调色板颜色索引
	
	//调色板
	fseek(fio,sizeof(BITMAPFILEHEADER)+sizeof(BITMAPINFOHEADER),SEEK_SET);	
	fread(temp,sizeof(RGBQUAD),256,fio);	//读取256色的调色板
	for(int ii=0;ii<=255;ii++)	//读取每一个颜色的RGB和对应的索引
	{
		byte B = *temp;
		temp++;
		byte G = *temp;
		temp++;
		byte R = *temp;
		temp++;
		byte reserved = *temp;
		temp++;
		fprintf(fo2,"%3d = (%3d,%3d,%3d)\n",ii,R,G,B);	//分别输出每一个颜色的索引和RGB
	}
	fclose(fo2);
	temp-=1024;	//将指针temp复位至调色板开头
	
	//统计各个颜色的像素个数
	for(ii=0;ii<=255;ii++)	//Pixel_list数组初始化
	{
		Pixel_list[ii]=0;
	}
	fseek(fio,offBits,SEEK_SET);	//调节文件指针至像素数据开头
	fread(Mdata,len,sizeof(char),fio);	//读取像素数据
	for(jj=nHeig-1;jj>=0;jj--)	//调节坐标系
	{
		for(ii=0;ii<nWidt;ii++)
		{
			kk=jj*nWidt+ii;
			ch=*(Mdata+kk);
			(Pixel_list[ch])++;	//当前像素对应的计数器自增
		}
	}
	for(ii=0;ii<=255;ii++)	//输出各个颜色的索引、对应的像素个数和对应的RGB
	{
		byte B = *temp;
		temp++;
		byte G = *temp;
		temp++;
		byte R = *temp;
		temp+=2;	//跳过rgbReserved
		fprintf(fo2,"%3d = (%3d,%3d,%3d)\n",ii,R,G,B);	//输出调色板至文件
		fprintf(fou,"Index = %4d, Count = %6d, RGB = (%3d,%3d,%3d)\n",ii,Pixel_list[ii],R,G,B);
	}
	delete []Mdata;
	return true;
}
bool _fastcall ReadBmpFileToDataFunc(FILE *fio,FILE *fou)
{
	//变量定义
	BITMAPFILEHEADER bmfh;
	fread(&bmfh,sizeof(BITMAPFILEHEADER),1,fio);	//位图文件头
	BITMAPINFOHEADER bmih;
	fread(&bmih,sizeof(BITMAPINFOHEADER),1,fio);	//位图信息头
	RGBQUAD rgb;
	fread(&rgb,sizeof(RGBQUAD),1,fio);	//调色板头
	//报错可能
	if(bmfh.bfType !=0x4D42)
	{
		strcpy(TextStr,"图像格式BM错误！");
		return false;
	}
	if(bmih.biCompression !=BI_RGB)
	{
		strcpy(TextStr,"图像压缩格式错误！");
		return false;
	}
	if(bmih.biBitCount !=8)
	{
		strcpy(TextStr,"非256色错误！");
		return false;
	}
	return ReadBmpBy_8BitFileFunc(fio,fou,bmfh,bmih,rgb);

}
int main(int argc, char* argv[])
{
	FILE *fio=fopen("E:\\1.bmp","rb");	//原图片
	if(!fio)
	{
		printf("bmp文件打开错误！");
		return 0;
	}
	FILE *fou=fopen("E:\\bmp.txt","w");
	if(!fou)
	{
		fclose(fio);
		printf("txt文件打开错误！");
		return 0;
	}
	if(ReadBmpFileToDataFunc(fio,fou))	//完成提醒
		printf("像素统计完成!\n");
	fclose(fio);
	fclose(fou);
	return 0;
}