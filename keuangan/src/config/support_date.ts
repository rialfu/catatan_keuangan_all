export function get_last_day_month_from_date(date: Date): Date{
    return new Date(date.getFullYear(), date.getMonth() + 1, 0)
}

export function get_last_day_month_string_from_date(date: Date): string{
    return get_last_day_month_from_date(date).toISOString().split('T')[0];
}
export function get_last_day_month_string_from_string(date: string): string{
    return get_last_day_month_string_from_date(new Date(date))
}


export function get_first_day_month_from_date(date: Date): Date{
    return new Date(date.getFullYear(), date.getMonth(), 1)
}

export function get_first_day_month_string_from_date(date: Date): string{
    return get_first_day_month_from_date(date).toISOString().split('T')[0];
}
export function get_first_day_month_string_from_string(date: string): string{
    return get_first_day_month_string_from_date(new Date(date))
}

export function isStringDate(date: string): boolean{
    return !isNaN(new Date(date).getDate());
}
export function isStringDateYYYYMMDD(date: string): boolean{
    const result:boolean = isStringDate(date)
    if(result == false) return false;
    const regex = new RegExp(/^\d{4}\-(0[1-9]|1[0-2])\-(0[1-9]{1})$/)
    return regex.test(date)
    // return false;
}