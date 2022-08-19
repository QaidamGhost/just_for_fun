#include "stdio.h"
#include "windows.h"

//�Ի����ҿ�������Ⱦɫ��ʹʯӢ��б��ʯ�����Գ�ʯ���ֲ�ͬ����ɫ���ֱ�ʻҰ�ɫ����ɫ����ɫ����
//����Ⱦɫ�����Ƭ���ز��������ݸ�ʽΪ8λ256ɫbmp��������Ϊ1.bmp��������߼���E�̵ĸ�Ŀ¼�¡�
//���к������¼�����������txt�ļ���������SPSS��RGBֵ���о��������ͳ�����������
//�޳�������ɫ�������QAF������Ԫ�����ռ�ȡ�

char TextStr[100];//������Ϣ
int Pixel_list[256];//���ؼ�����

bool _fastcall ReadBmpBy_8BitFileFunc(FILE *fio,FILE *fou,BITMAPFILEHEADER bmfh,BITMAPINFOHEADER bmih,RGBQUAD rgb)
{
	//��������
	DWORD offBits = bmfh.bfOffBits;	//�ļ�ͷ���������ݼ�ľ���
	LONG nWidt = bmih.biWidth;	//ͼƬ���
	LONG nHeig = bmih.biHeight;	//ͼƬ�߶�
	byte *temp = new byte[1024];	//���ڶ�ȡ��ɫ��
	FILE *fo2=fopen("E:\\color_table.txt","w");	//��ɫ�����txt
	if(!fo2)
	{
		printf("txt�ļ��򿪴���");
		return 0;
	}
	int datype = 1;	//256ɫÿ������1�ֽ�
	long len = nWidt*nHeig*datype;	//���������ֽ���
	char *Mdata = new char[len+1];	//���ڶ�ȡ��������
	if(!Mdata)
	{
		strcpy(TextStr,"�ڴ����");
		return false;
	}
	long kk,jj;	//ѭ������
	UCHAR ch;	//��ɫ����ɫ����
	
	//��ɫ��
	fseek(fio,sizeof(BITMAPFILEHEADER)+sizeof(BITMAPINFOHEADER),SEEK_SET);	
	fread(temp,sizeof(RGBQUAD),256,fio);	//��ȡ256ɫ�ĵ�ɫ��
	for(int ii=0;ii<=255;ii++)	//��ȡÿһ����ɫ��RGB�Ͷ�Ӧ������
	{
		byte B = *temp;
		temp++;
		byte G = *temp;
		temp++;
		byte R = *temp;
		temp++;
		byte reserved = *temp;
		temp++;
		fprintf(fo2,"%3d = (%3d,%3d,%3d)\n",ii,R,G,B);	//�ֱ����ÿһ����ɫ��������RGB
	}
	fclose(fo2);
	temp-=1024;	//��ָ��temp��λ����ɫ�忪ͷ
	
	//ͳ�Ƹ�����ɫ�����ظ���
	for(ii=0;ii<=255;ii++)	//Pixel_list�����ʼ��
	{
		Pixel_list[ii]=0;
	}
	fseek(fio,offBits,SEEK_SET);	//�����ļ�ָ�����������ݿ�ͷ
	fread(Mdata,len,sizeof(char),fio);	//��ȡ��������
	for(jj=nHeig-1;jj>=0;jj--)	//��������ϵ
	{
		for(ii=0;ii<nWidt;ii++)
		{
			kk=jj*nWidt+ii;
			ch=*(Mdata+kk);
			(Pixel_list[ch])++;	//��ǰ���ض�Ӧ�ļ���������
		}
	}
	for(ii=0;ii<=255;ii++)	//���������ɫ����������Ӧ�����ظ����Ͷ�Ӧ��RGB
	{
		byte B = *temp;
		temp++;
		byte G = *temp;
		temp++;
		byte R = *temp;
		temp+=2;	//����rgbReserved
		fprintf(fo2,"%3d = (%3d,%3d,%3d)\n",ii,R,G,B);	//�����ɫ�����ļ�
		fprintf(fou,"Index = %4d, Count = %6d, RGB = (%3d,%3d,%3d)\n",ii,Pixel_list[ii],R,G,B);
	}
	delete []Mdata;
	return true;
}
bool _fastcall ReadBmpFileToDataFunc(FILE *fio,FILE *fou)
{
	//��������
	BITMAPFILEHEADER bmfh;
	fread(&bmfh,sizeof(BITMAPFILEHEADER),1,fio);	//λͼ�ļ�ͷ
	BITMAPINFOHEADER bmih;
	fread(&bmih,sizeof(BITMAPINFOHEADER),1,fio);	//λͼ��Ϣͷ
	RGBQUAD rgb;
	fread(&rgb,sizeof(RGBQUAD),1,fio);	//��ɫ��ͷ
	//�������
	if(bmfh.bfType !=0x4D42)
	{
		strcpy(TextStr,"ͼ���ʽBM����");
		return false;
	}
	if(bmih.biCompression !=BI_RGB)
	{
		strcpy(TextStr,"ͼ��ѹ����ʽ����");
		return false;
	}
	if(bmih.biBitCount !=8)
	{
		strcpy(TextStr,"��256ɫ����");
		return false;
	}
	return ReadBmpBy_8BitFileFunc(fio,fou,bmfh,bmih,rgb);

}
int main(int argc, char* argv[])
{
	FILE *fio=fopen("E:\\1.bmp","rb");	//ԭͼƬ
	if(!fio)
	{
		printf("bmp�ļ��򿪴���");
		return 0;
	}
	FILE *fou=fopen("E:\\bmp.txt","w");
	if(!fou)
	{
		fclose(fio);
		printf("txt�ļ��򿪴���");
		return 0;
	}
	if(ReadBmpFileToDataFunc(fio,fou))	//�������
		printf("����ͳ�����!\n");
	fclose(fio);
	fclose(fou);
	return 0;
}