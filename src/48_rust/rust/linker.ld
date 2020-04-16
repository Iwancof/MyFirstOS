  
/*
kernel.ls
kotetuco 2008 - 2016
*/

/*入力オブジェクトファイル(将来的にMakefileで定義)*/

/*出力オブジェクトファイル(Makefileで定義)*/

ENTRY(os_init)

/*出力フォーマット*/
OUTPUT_FORMAT("binary")

/*セクション*/
SECTIONS{
	/*.textセクションのメモリ開始位置*/
	.text 0x6000 : SUBALIGN(1)
	{
		/*.textセクション全部を含む*/
		*(.text.init_os)
		*(.text*)
	}

	/*.dataセクションのメモリ開始位置*/
	.data 0x7000:
	/*.data :*/

	/*.dataセクションのファイル上の開始位置*/
	AT(0x7000) SUBALIGN(4)
	{
		*(.data)
		*(.rodata*)
	}

	/* 上記以外のセクションは無視する */
	/DISCARD/ : {*(*)}
}